defmodule OutboxEx.Storage do
  alias OutboxEx.Storage.Event
  alias OutboxEx.Config

  import Ecto.Query

  def event_query(%Config{table: source}) do
    Event
    |> from()
    |> Map.update!(:from, &Map.put(&1, :source, {source, OutboxEx.Storage.Event}))
  end

  def mark_as_synchronized(%Config{} = config, event) do
    {_, _} =
      config
      |> event_query()
      |> where([e], e.uuid == ^event.uuid and is_nil(e.synchronized_at))
      |> config.repo.update_all(set: [synchronized_at: DateTime.utc_now()])

    :ok
  end
end
