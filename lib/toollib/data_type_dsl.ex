defmodule DataTypeDSL do
  @doc false
  defmacro __using__(_opts) do
    quote do
      import DataTypeDSL

      @component_names []
      @component_types []

      @before_compile DataTypeDSL
    end
  end

  defmacro component(name, type \\ :ST) do
    data_type = Module.concat([Atom.to_string(type) <> "DataType"])
    Code.ensure_loaded(data_type)

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
                     data_type = Module.concat([Atom.to_string(type) <> "DataType"])
                     Keyword.put(acc, name, {
                       :%, [], [{
                         :__aliases__,
                         [alias: false],
                         [data_type]
                       }, {:%{}, [], []}]
                     })
                   end)

    type_struct = List.zip([component_names, component_types])
                  |> List.foldr([], fn({name, type}, acc) ->
                    data_type = Module.concat([Atom.to_string(type) <> "DataType"])
                    Keyword.put(acc, name, {
                      {:., [], [{
                        :__aliases__,
                        [alias: false],
                        [data_type]
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
        List.zip([Enum.reverse(@component_names), Enum.reverse(@component_types), field.components])
        |> create_derivative_field(__MODULE__, %__MODULE__{})
      end

      def from_component(component) do
        List.zip([Enum.reverse(@component_names), Enum.reverse(@component_types), Tuple.to_list(component.subcomponents)])
        |> create_derivative_component(__MODULE__, %__MODULE__{})
      end

      def to_field(data) do
        # return a %Field{} object with the right data in the right place

      end

      def to_component(data) do
        # return a %Component{} object with the right data in the right place

      end
    end
  end

  def create_derivative_field(component_pairs, module, empty_target) do
    # field_pairs: [{name, type, %Field{}}]
    component_pairs |> List.foldr(empty_target, fn({name, type, component}, acc) ->
      data_type = Module.concat([Atom.to_string(type) <> "DataType"])
      Code.ensure_loaded(data_type)
      with_method = String.to_atom("with_" <> Atom.to_string(name))
      apply(module, with_method, [acc, apply(data_type, :from_component, [component])])
    end)
  end

  def create_derivative_component(subcomponent_pairs, module, empty_target) do
    # field_pairs: [{name, type, %Field{}}]
    subcomponent_pairs |> List.foldr(empty_target, fn({name, type, subcomponent}, acc) ->
      data_type = Module.concat([Atom.to_string(type) <> "DataType"])
      Code.ensure_loaded(data_type)
      with_method = String.to_atom("with_" <> Atom.to_string(name))
      apply(module, with_method, [acc, apply(data_type, :from_string, [subcomponent])])
    end)
  end
end
