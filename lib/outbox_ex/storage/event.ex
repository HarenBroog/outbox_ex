defmodule OutboxEx.Storage.Event do
  use Ecto.Schema

  @primary_key false
  schema "_" do
    field :uuid, :binary_id, primary_key: true
    field :causation_id, :string
    field :correlation_id, :string

    field :type, :string
    field :topic, :string
    field :partition_key, :string

    field :data, :map
    field :metadata, :map

    field :occurred_at, :utc_datetime_usec
    field :synchronized_at, :utc_datetime_usec
  end

  def changeset(schema, attrs) do
    import Ecto.Changeset

    schema
    |> cast(attrs, [
      :uuid,
      :causation_id,
      :correlation_id,
      :type,
      :topic,
      :partition_key,
      :data,
      :metadata,
      :occurred_at
    ])
    |> validate_required([:type, :data, :occurred_at])
  end

  defimpl String.Chars do
    def to_string(event) do
      "#OutboxEx.Storage.Event<source: #{event.__meta__.source}, uuid: #{event.uuid}>"
    end
  end
end
