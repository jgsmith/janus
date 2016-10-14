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
      @current_description ""
      @current_message_structure nil
      @current_ack_structure nil

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro message_type(type) do
    quote do
      @message_type unquote(type)
    end
  end

  defmacro description(text) do
    quote do
      @current_description unquote(text)
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

  defmacro event(type) do
    process_event_info(type)
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      unquote(process_event_info(nil))

      @spec find_message_event(Message.t) :: MessageEvent.t
      def find_message_event(message) do
        # find out if the message type is in our list or not
        msh =
          List.first(Message.segments(message, "MSH"))
          |> Mensendi.Segments.MSH.from_segment
        # message_type = msh.message_type.message_event
        trigger_code = msh.message_type.trigger_event
        @events |> Enum.find(fn(event) ->
          event.event == trigger_code
        end)
      end
    end
  end

  defp process_event_info(type) do
    quote do
      @events [%MessageEvent{
        event: Atom.to_string(@current_event),
        description: @current_description,
        message_structure: @current_message_structure,
        ack_structure: @current_ack_structure
      } | @events]
      @current_event unquote(type)
    end
  end
end
