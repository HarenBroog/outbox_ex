defmodule OutboxEx.Sink.Adapter do
  alias OutboxEx.Storage.Event
  @callback transmit(Event.t()) :: :ok | {:error, reason :: any()}
end
