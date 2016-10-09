defmodule Mensendi.DSL.DSLHelpers do
  @moduledoc false

  def field_functions(field_pairs, calling_module) do
    {:__block__, [],
      field_pairs |> Enum.map(&(field_function(&1, calling_module)))
    }
  end

  def field_function({name, type}, calling_module) do
    data_type = Module.concat([:Mensendi, :DataTypes, type])
    quote do
      @spec unquote(:"with_#{name}")(unquote(calling_module).t, unquote(data_type).t) :: unquote(calling_module).t
      def unquote(:"with_#{name}")(data_object, new_value) do
        Map.put(data_object, unquote(name), new_value)
      end
    end
  end
end
