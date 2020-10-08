defmodule OutboxEx.Relay.Naive do
  @behaviour OutboxEx.Relay.Adapter

  use GenServer
  import Ecto.Query
  alias OutboxEx.Config
  alias OutboxEx.Storage

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: Module.concat(config.module, __MODULE__))
  end

  def child_spec(config) do
    %{
      id: Module.concat(config.module, __MODULE__),
      start: {__MODULE__, :start_link, [config]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def init(config) do
    {:ok, config, {:continue, :start}}
  end

  def handle_continue(:start, config) do
    Process.send_after(self(), :work, 1000)

    {:noreply, config}
  end

  def handle_info(:work, config) do
    Process.send_after(self(), :work, 1000)

    config
    |> fetch_events()
    |> Enum.each(fn event ->
      :ok = config.sink_adapter.transmit(event)
      :ok = Storage.mark_as_synchronized(config, event)
    end)

    {:noreply, config}
  end

  def fetch_events(%Config{repo: repo} = config) do
    config
    |> Storage.event_query()
    |> order_by([e], asc: e.occurred_at)
    |> where([e], is_nil(e.synchronized_at))
    |> limit(1)
    |> repo.all()
  end
end
