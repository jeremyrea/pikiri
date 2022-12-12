defmodule Pikiri.Logs do
  alias Pikiri.{Repo, Logs.Log}

  @type t :: %Log{}

  @spec create_log_event(map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def create_log_event(params) do
    %Log{}
    |> Log.changeset(params)
    |> Repo.insert()
  end
end
