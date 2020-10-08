defmodule OutboxEx.Storage.Migrations do
  defmodule V1 do
    @moduledoc false

    use Ecto.Migration

    def up(table_name) do
      create table(table_name, primary_key: false) do
        add :uuid, :binary_id, primary_key: true
        add :causation_id, :string
        add :correlation_id, :string

        add :type, :string, null: false
        add :topic, :string
        add :partition_key, :string

        add :data, :map, null: false
        add :metadata, :map

        add :occurred_at, :utc_datetime_usec, null: false, default: fragment("now()")
        add :synchronized_at, :utc_datetime_usec
      end

      create index(table_name, ["occurred_at ASC"],
               where: "synchronized_at = NULL",
               name: "#{table_name}_occurred_at_ordered_index"
             )
    end

    def down(table_name) do
      drop_if_exists index(table_name, name: "#{table_name}_occurred_at_ordered_index")
      drop table(table_name)
    end
  end
end
