defmodule OutboxEx.Config do
  @type adapter :: {atom(), keyword()}

  @type t :: %__MODULE__{
          module: atom(),
          sink_adapters: list(adapter),
          relay_adapter: adapter,
          repo: Ecto.Repo.t(),
          table: binary()
        }

  @enforce_keys [
    :module,
    :sink_adapters,
    :relay_adapter,
    :repo,
    :table
  ]

  defstruct [
    :module,
    :sink_adapters,
    :relay_adapter,
    :repo,
    :table
  ]

  def load(otp_app, module) do
    otp_app
    |> Application.get_env(module)
    |> Keyword.put(:module, module)
    |> new()
  end

  def new(attrs) do
    struct!(__MODULE__, attrs)
  end
end
