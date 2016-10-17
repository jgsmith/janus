defmodule Mensendi.DSL.Message do
  alias Mensendi.Data.{Message, MessageEvent}
  alias Mensendi.Utils.MessageGrammar

  @doc false
  defmacro __using__(_opts) do
    quote do
      alias Mensendi.Data.{Message, MessageEvent}
      import unquote(__MODULE__)

      @events []
      @message_type nil
      @current_event nil
      @current_event_class :informational
      @current_ack_type "ACK"
      @current_description ""
      @current_message_structure nil
      @current_ack_structure nil
      @current_title ""

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro message_type(type) do
    quote do
      @message_type unquote(type)
    end
  end

  defmacro ack_type(type) do
    quote do
      @current_ack_type unquote(type)
    end
  end

  defmacro description(text) do
    quote do
      @current_description unquote(text)
    end
  end

  defmacro title(text) do
    quote do
      @current_title unquote(text)
    end
  end

  defmacro message_structure(text) do
    quote do
      @current_message_structure MessageGrammar.compile(unquote(text))
    end
  end

  defmacro ack_structure(text) do
    quote do
      @current_ack_structure MessageGrammar.compile(unquote(text))
    end
  end

  @doc """
  Specifies the HL7 event type and class.

  The event class is one of `:informational` (default) or `:query`.
  Informational events will trigger a cascade of events in the Mensendi system.
  Query events will result in a response based on the data stored in Mensendi.

  *N.B.*: This macro serves as the start of a new event definition. Any previous
  information will be saved as part of the previous event, if any.
  """
  defmacro event(event_type, event_class \\ :informational) do
    process_event_info(event_type, event_class, __CALLER__.module)
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      use OkJose

      unquote(process_event_info(nil, nil, __CALLER__.module))

      @moduledoc unquote(generate_documentation(__CALLER__.module))

      @doc false
      @spec find_message_event(String.t) :: MessageEvent.t
      def find_message_event(trigger_code) do
        @events
        |> Enum.find(fn(event) ->
          event.event == trigger_code
        end)
        |> wrap_found_message_event
      end

      defp wrap_found_message_event(%MessageEvent{} = event) do
        {:ok, event}
      end

      defp wrap_found_message_event(_) do
        {:error, "No event found"}
      end
    end
  end

  defp generate_documentation(module) do
    message_type = Module.get_attribute(module, :message_type)

    # This gets the last event defined since the redefinition of @events doesn't run before this
    events = [%MessageEvent{
      event: Atom.to_string(Module.get_attribute(module, :current_event)),
      type: Module.get_attribute(module, :current_event_class),
      title: Module.get_attribute(module, :current_title),
      description: Module.get_attribute(module, :current_description),
      message_structure: Module.get_attribute(module, :current_message_structure),
      ack_structure: Module.get_attribute(module, :current_ack_structure),
      ack_type: Module.get_attribute(module, :current_ack_type)
    } | Module.get_attribute(module, :events)]

    ~s"""
    Message structures and events for generic #{message_type} messages.

    #{generate_documentation(events, module)}
    """
  end

  defp generate_documentation(events, module) when is_list(events) do
    events
    |> Enum.reverse
    |> Enum.drop(1)
    |> Enum.map(&(generate_documentation(&1, module)))
    |> Enum.join("\n\n\n")
  end

  defp generate_documentation(%{
    event: event_type,
    title: title,
    message_structure: message_structure,
    ack_structure: ack_structure,
    description: description,
    ack_type: ack_message_type
  } = _event, module) do
    message_type = Module.get_attribute(module, :message_type)

    ~s"""
    ### #{message_type}/#{ack_message_type} - #{title} (Event #{event_type})

    #{description}

    #### Message Structure

    ```
    #{MessageGrammar.uncompile(message_structure)}
    ```

    #### Acknowledgement Structure

    ```
    #{MessageGrammar.uncompile(ack_structure)}
    ```
    """
  end

  defp process_event_info(type, class, _module) do
    quote do
      @events [%MessageEvent{
        event: Atom.to_string(@current_event),
        type: @current_event_class,
        title: @current_title,
        description: @current_description,
        message_structure: @current_message_structure,
        ack_structure: @current_ack_structure,
        ack_type: @current_ack_type
      } | @events]

      @current_event unquote(type)
      @current_event_class unquote(class)
    end
  end
end
