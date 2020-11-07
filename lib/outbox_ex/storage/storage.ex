defmodule OutboxEx.Storage do
  alias OutboxEx.Storage.Event
  alias OutboxEx.Config

  import Ecto.Query

  def enqueue(%Config{} = config, attrs) do
    %Event{}
    |> Event.changeset(attrs)
    |> put_source(config)
    |> config.repo.insert()
  end

  def mark_as_synchronized(%Config{} = config, event_uuids) do
    event_uuids = List.wrap(event_uuids)

    {_, _} =
      config
      |> query()
      |> where([e], e.uuid in ^event_uuids and is_nil(e.synchronized_at))
      |> config.repo.update_all(set: [synchronized_at: DateTime.utc_now()])

    :ok
  end

  def query(%Config{} = config) do
    Event
    |> from()
    |> put_source(config)
  end

  def lock(%Config{module: module, repo: repo}) do
    lock_key = module |> to_string() |> :erlang.phash2()

    repo
    |> Ecto.Adapters.SQL.query!("SELECT pg_try_advisory_xact_lock(#{lock_key})", [])
    |> case do
      %{rows: [[true]]} ->
        :ok

      _ ->
        :error
    end
  end

  defp put_source(%Ecto.Query{} = query, %Config{table: table}) do
    query
    |> Map.update!(:from, &Map.put(&1, :source, {table, OutboxEx.Storage.Event}))
  end

  defp put_source(%Ecto.Changeset{data: %Event{}} = changeset, %Config{table: table}) do
    changeset
    |> put_in([Access.key!(:data), Access.key!(:__meta__), Access.key!(:source)], table)
  end
end
