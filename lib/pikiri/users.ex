defmodule Pikiri.Users do
  alias Pikiri.{Repo, Users.User}
  import Ecto.Query

  @type t :: %User{}

  @spec create_user(map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def create_user(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end

  @spec set_role(t(), t()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def set_role(user, role) do
    user
    |> User.changeset_role(%{role: role})
    |> Repo.update()
  end

  @spec is_admin?(t()) :: boolean()
  def is_admin?(%{role: "admin"}), do: true
  def is_admin?(_any), do: false

  def list_users() do
    User 
    |> order_by(desc: :id) 
    |> Repo.all
  end

  @spec get_user(Ecto.UUID) :: User
  def get_user(uuid), do: User |> Repo.get(uuid)

  @spec delete_user(Ecto.UUID) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def delete_user(uuid), do: %User{uuid: uuid} |> Repo.delete
end