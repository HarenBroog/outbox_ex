defmodule OutboxEx do
  @moduledoc """
  """

  defmacro __using__(opts) do
    quote do
      alias OutboxEx.Storage.Event

      def start_link(opts \\ []) do
        import Supervisor.Spec, warn: false

        name = opts |> Keyword.get(:name, __MODULE__)

        config = config()

        children = [
          {config.relay_adapter, config}
        ]

        opts = [strategy: :one_for_one, name: name]

        Supervisor.start_link(children, opts)
      end

      def child_spec(opts) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [opts]},
          type: :supervisor,
          restart: :permanent,
          shutdown: 500
        }
      end

      def enqueue(event) do
        %Event{}
        |> Event.changeset(event)
        |> config().repo.insert()
      end

      def config do
        OutboxEx.Config.load(unquote(opts[:otp_app]), __MODULE__)
      end
    end
  end
end
