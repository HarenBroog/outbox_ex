defmodule OutboxEx.Sink.Adapter do
  alias OutboxEx.Storage.Event
  @callback __struct__() :: struct()
  @callback transmit(Event.t()) :: :ok | {:error, reason :: any()}
end
