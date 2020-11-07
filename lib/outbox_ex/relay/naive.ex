defmodule OutboxEx.Relay.Naive do
  @behaviour OutboxEx.Relay.Adapter

  defstruct log_query: false,
            interval_ms: 100,
            batch_size: 500

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

  def init(%Config{} = config) do
    {:ok, config, {:continue, :start}}
  end

  def handle_continue(:start, %Config{relay_adapter: %{interval_ms: interval_ms}} = config) do
    Process.send_after(self(), :work, interval_ms)

    {:noreply, config}
  end

  def handle_info(:work, %Config{relay_adapter: %{interval_ms: interval_ms}} = config) do
    process_events(config)

    Process.send_after(self(), :work, interval_ms)
    {:noreply, config}
  end

  defp process_events(
         %Config{repo: repo, relay_adapter: %{batch_size: batch_size, log_query: log_query}} =
           config
       ) do
    repo.transaction(fn ->
      :ok = Storage.lock(config)

      config
      |> Storage.query()
      |> order_by([e], asc: e.occurred_at)
      |> where([e], is_nil(e.synchronized_at))
      |> limit(^batch_size)
      |> repo.all(log: log_query)
      |> Enum.each(fn event ->
        config.sink_adapters
        |> Enum.each(fn adapter ->
          :ok = adapter.transmit(event)
        end)

        :ok = Storage.mark_as_synchronized(config, event.uuid)
      end)
    end)
  end
end
