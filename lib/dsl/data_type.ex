defmodule Mensendi.DSL.DataType do
  alias Mensendi.DSL.DSLHelpers

  @moduledoc """
  A DSL for defining HL7 data types. Each data type is composed of a number of named
  components, each with their own corresponding data type. The resulting modules will
  have `from_field/1` and `from_component/1` functions that will draw the data from the right
  part of the message data to fill all of the named slots in the data type structure.
  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)

      @components []

      @before_compile unquote(__MODULE__)
    end
  end

  @doc """
  Adds a named data slot to the data type.

  The second argument is an atom naming the HL7 data
  type that should be assumed for this slot. Do not include the `Mensendi.DataTypes.` prefix.
  """
  defmacro component(name, type) do
    quote do
      @components [{unquote(name), unquote(type)} | @components]
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    component_pairs = Enum.reverse(Module.get_attribute(__CALLER__.module, :components))

    module_name = Module.split(__CALLER__.module) |> Enum.join(".") |> String.to_atom

    field_struct = component_pairs
                   |> List.foldr([], fn({name, type}, acc) ->
                     Keyword.put(acc, name, {
                       :%, [], [{
                         :__aliases__,
                         [alias: false],
                         [Module.concat([:Mensendi, :DataTypes, type])]
                       }, {:%{}, [], []}]
                     })
                   end)

    type_struct = component_pairs
                  |> List.foldr([], fn({name, type}, acc) ->
                    Keyword.put(acc, name, {
                      {:., [], [{
                        :__aliases__,
                        [alias: false],
                        [Module.concat([:Mensendi, :DataTypes, type])]
                      }, :t]},
                      [],
                      []
                    })
                  end)

    quote do
      @components Enum.reverse(@components)

      unquote({
        :@,
        [context: __MODULE__, import: Kernel],
        [{
          :type,
          [],
          [{
            :::,
            [],
            [{:t, [], __MODULE__},
            {
              :%,
              [],
              [{
                :__aliases__,
                [alias: false],
                [module_name]
              },
              {
                :%{},
                [],
                type_struct
              }]
            }]
          }]
        }]
      })

      unquote({
        :defstruct,
        [
          context: __MODULE__,
          import: Kernel
        ],
        [
          field_struct
        ]
      })

      unquote(component_pairs |> DSLHelpers.field_functions(__CALLER__.module))

      @spec from_field(Mensendi.Data.Field.t) :: unquote(__CALLER__.module).t
      def from_field(field) do
        # return an object with the right type and info pulled from the segment
        field.components
        |> create_derivative_field({@components, __MODULE__, %__MODULE__{}})
      end

      @spec from_component(Mensendi.Data.Component.t) :: unquote(__CALLER__.module).t
      def from_component(component) do
        component.subcomponents
        |> Tuple.to_list
        |> create_derivative_component({@components, __MODULE__, %__MODULE__{}})
      end
    end
  end

  @doc false
  def create_derivative_field(things, meta) do
    # field_pairs: [{{name, type}, %Field{}}]
    create_derivative_thing(things, meta, :from_component)
  end

  @doc false
  def create_derivative_component(things, meta) do
    # field_pairs: [{{name, type}, %Field{}}]
    create_derivative_thing(things, meta, :from_string)
  end

  defp create_derivative_thing(things, {components, module, empty_target}, method) do
    List.zip([components, things])
    |> List.foldr(empty_target, fn({{name, type}, thing}, acc) ->
      data_type = Module.concat([:Mensendi, :DataTypes, type])
      Code.ensure_loaded(data_type)
      with_method = :"with_#{name}"
      apply(module, with_method, [acc, apply(data_type, method, [thing])])
    end)
  end
end
