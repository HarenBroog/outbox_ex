defmodule OutboxEx.Sink.Console do
  @behaviour OutboxEx.Sink.Adapter
  alias OutboxEx.Storage.Event

  defstruct []

  def transmit(%Event{} = event) do
    IO.inspect("OutboxEx.Sink.Console transmitted event: #{event}")
    :ok
  end
end
