defmodule Mensendi.DSL.DataType do
  @doc false
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)

      @component_names []
      @component_types []

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro component(name, type \\ :ST) do
    Module.concat([Atom.to_string(type) <> "DataType"])
    |> Code.ensure_loaded

    quote do
      @component_names [unquote(name) | @component_names]
      @component_types [unquote(type) | @component_types]

      def unquote(String.to_atom("with_" <> Atom.to_string(name)))(field, data) do
        unquote({
          :put_in,
          [context: __MODULE__, import: Kernel],
          [{
            {
              :.,
              [],
              [{:field, [], __MODULE__},
               name
              ]
            },
            [],
            []
          },
          {:data, [], __MODULE__}
          ]
        })
      end
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    # quote do
    #   @component_names Enum.reverse(@component_names)
    #   @component_types Enum.reverse(@component_types)
    # end

    component_names = Enum.reverse(Module.get_attribute(__CALLER__.module, :component_names))
    component_types = Enum.reverse(Module.get_attribute(__CALLER__.module, :component_types))

    module_name = Module.split(__CALLER__.module) |> Enum.join(".") |> String.to_atom

    field_struct = List.zip([component_names, component_types])
                   |> List.foldr([], fn({name, type}, acc) ->
                     Keyword.put(acc, name, {
                       :%, [], [{
                         :__aliases__,
                         [alias: false],
                         [Module.concat([Atom.to_string(type) <> "DataType"])]
                       }, {:%{}, [], []}]
                     })
                   end)

    type_struct = List.zip([component_names, component_types])
                  |> List.foldr([], fn({name, type}, acc) ->
                    Keyword.put(acc, name, {
                      {:., [], [{
                        :__aliases__,
                        [alias: false],
                        [Module.concat([Atom.to_string(type) <> "DataType"])]
                      }, :t]},
                      [],
                      []
                    })
                  end)

    quote do
      @component_names Enum.reverse(@component_names)
      @component_types Enum.reverse(@component_types)

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

      def from_field(field) do
        # return an object with the right type and info pulled from the segment
        field.components
        |> create_derivative_field({@component_names, @component_types, __MODULE__, %__MODULE__{}})
      end

      def from_component(component) do
        component.subcomponents
        |> Tuple.to_list
        |> create_derivative_component({@component_names, @component_types, __MODULE__, %__MODULE__{}})
      end

      def to_field(data) do
        # return a %Field{} object with the right data in the right place

      end

      def to_component(data) do
        # return a %Component{} object with the right data in the right place

      end
    end
  end

  def create_derivative_field(things, meta) do
    # field_pairs: [{name, type, %Field{}}]
    create_derivative_thing(things, meta, :from_component)
  end

  def create_derivative_component(things, meta) do
    # field_pairs: [{name, type, %Field{}}]
    create_derivative_thing(things, meta, :from_string)
  end

  defp create_derivative_thing(things, {component_names, component_types, module, empty_target}, method) do
    List.zip([component_names, component_types, things])
    |> List.foldr(empty_target, fn({name, type, thing}, acc) ->
      data_type = Module.concat([Atom.to_string(type) <> "DataType"])
      Code.ensure_loaded(data_type)
      with_method = String.to_atom("with_" <> Atom.to_string(name))
      apply(module, with_method, [acc, apply(data_type, method, [thing])])
    end)
  end
end
