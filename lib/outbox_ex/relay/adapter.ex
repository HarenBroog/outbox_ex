defmodule OutboxEx.Relay.Adapter do
  @callback __struct__() :: struct()
  @callback start_link(opts :: keyword()) :: {:ok, pid()}
end
