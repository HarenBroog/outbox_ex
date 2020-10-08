defmodule OutboxEx.Relay.Adapter do
  alias OutboxEx.Config
  @callback fetch_events(Config.t()) :: list(struct())
  @callback start_link(opts :: keyword()) :: {:ok, pid()}
end
