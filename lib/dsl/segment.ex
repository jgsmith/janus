defmodule Mensendi.DSL.Segment do
  alias Mensendi.DSL.DSLHelpers

  @doc false
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)

      @fields [{:segment_name, :ST}]

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro field(name, type) do
    Module.concat([:Mensendi, :DataTypes, type])
    |> Code.ensure_loaded

    quote do
      @fields [{unquote(name), unquote(type)} | @fields]
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    fields = Enum.reverse(Module.get_attribute(__CALLER__.module, :fields))

    module_name = Module.split(__CALLER__.module) |> Enum.join(".") |> String.to_atom

    field_struct = fields
                   |> List.foldr([], fn({name, type}, acc) ->
                     Keyword.put(acc, name, {
                       :%, [], [{
                         :__aliases__,
                         [alias: false],
                         [Module.concat([:Mensendi, :DataTypes, type])]
                       }, {:%{}, [], []}]
                     })
                   end)

    type_struct = fields
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
                [
                  children: {
                    :__aliases__,
                    [alias: false],
                    [:List]
                  }
                ] ++ type_struct
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
          [
            children: []
          ] ++ field_struct
        ]
      })

      # @spec with_segment_name(unquote(__MODULE__).t, Mendensi.Data.ST.t) :: unquote(__MODULE__).t
      # def with_segment_name(segment, value) do
      #   put_in(segment.segment_name, value)
      # end

      unquote(fields |> DSLHelpers.field_functions(__CALLER__.module))

      @fields Enum.reverse(@fields)

      @spec from_segment(Mensendi.Data.Segment.t) :: unquote(__CALLER__.module).t
      def from_segment(segment) do
        # return an object with the right type and info pulled from the segment
        List.zip([@fields, segment.fields])
        |> create_derivative_segment(__MODULE__, %__MODULE__{})
      end

      @spec to_segment(unquote(__CALLER__.module).t) :: Mensendi.Data.Segment.t
      def to_segment(data) do
        # return a %Segment{} object with the right data in the right place

      end
    end
  end

  @doc false
  def create_derivative_segment(field_pairs, module, empty_target) do
    # field_pairs: [{name, type, %Field{}}]
    field_pairs |> List.foldr(empty_target,
      fn({{name, type}, fields}, acc) ->
        data_type = Module.concat([:Mensendi, :DataTypes, type])
        Code.ensure_loaded(data_type)
        with_method = :"with_#{name}"
        apply(module, with_method, [acc,
          fields |> Enum.map(&(apply(data_type, :from_field, [&1])))
        ])
      end
    )
  end
end
