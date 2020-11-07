defmodule OutboxEx do
  @moduledoc """
  """

  defmacro __using__(opts) do
    quote do
      def start_link(opts \\ []) do
        import Supervisor.Spec, warn: false

        name = opts |> Keyword.get(:name, __MODULE__)

        config = config()

        children = [
          {config.relay_adapter.__struct__, config}
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

      def enqueue(event), do: OutboxEx.Storage.enqueue(config(), event)

      def config do
        build_adapter = fn {mod, opts} ->
          struct!(mod, opts)
        end

        unquote(opts[:otp_app])
        |> OutboxEx.Config.load(__MODULE__)
        |> Map.update!(:relay_adapter, build_adapter)
        |> Map.update!(:sink_adapters, &Enum.map(&1, build_adapter))
      end
    end
  end
end
