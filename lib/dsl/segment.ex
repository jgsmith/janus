defmodule Mensendi.DSL.Segment do
  @doc false
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)

      @field_names [:segment_name]
      @field_types [:ST]

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro field(name, type \\ :ST) do
    # make sure we have the data type loaded if it's defined - so we don't do it
    # later, when we're trying to pour a raw segment into a structured segment
    Module.concat([Atom.to_string(type) <> "DataType"])
    |> Code.ensure_loaded

    quote do
      @field_names [unquote(name) | @field_names]
      @field_types [unquote(type) | @field_types]

      def unquote(String.to_atom("with_" <> Atom.to_string(name)))(segment, data) do
        unquote({
          :put_in,
          [context: __MODULE__, import: Kernel],
          [{
            {
              :.,
              [],
              [{:segment, [], __MODULE__},
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
    #   @field_names Enum.reverse(@field_names)
    #   @field_types Enum.reverse(@field_types)
    # end

    field_names = Enum.reverse(Module.get_attribute(__CALLER__.module, :field_names))
    field_types = Enum.reverse(Module.get_attribute(__CALLER__.module, :field_types))

    module_name = Module.split(__CALLER__.module) |> Enum.join(".") |> String.to_atom

    field_struct = List.zip([field_names, field_types])
                   |> List.foldr([], fn({name, type}, acc) ->
                     Keyword.put(acc, name, {
                       :%, [], [{
                         :__aliases__,
                         [alias: false],
                         [Module.concat([:Mensendi, :DataTypes, type])]
                       }, {:%{}, [], []}]
                     })
                   end)

    type_struct = List.zip([field_names, field_types])
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

      def with_segment_name(segment, value) do
        put_in(segment.segment_name, value)
      end

      def from_segment(segment) do
        # return an object with the right type and info pulled from the segment
        List.zip([Enum.reverse(@field_names), Enum.reverse(@field_types), segment.fields])
        |> create_derivative_segment(__MODULE__, %__MODULE__{})
      end

      def to_segment(data) do
        # return a %Segment{} object with the right data in the right place

      end
    end
  end

  def create_derivative_segment(field_pairs, module, empty_target) do
    # field_pairs: [{name, type, %Field{}}]
    field_pairs |> List.foldr(empty_target,
      fn({name, type, fields}, acc) ->
        data_type = Module.concat([:Mensendi, :DataTypes, type])
        Code.ensure_loaded(data_type)
        with_method = String.to_atom("with_" <> Atom.to_string(name))
        apply(module, with_method, [acc,
          Enum.map(fields,
            fn(field) ->
              apply(data_type, :from_field, [field])
            end
          )
        ])
      end
    )
  end
end
