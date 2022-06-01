defmodule PikiriWeb.Plugs.EnsureRole do
  @moduledoc """
  This plug ensures that a user has a particular role.
  ## Example
      plug MyAppWeb.EnsureRolePlug, [:user, :admin]
      plug MyAppWeb.EnsureRolePlug, :admin
      plug MyAppWeb.EnsureRolePlug, ~w(user admin)a
  """
  import Plug.Conn, only: [halt: 1, assign: 3]

  alias PikiriWeb.Router.Helpers, as: Routes
  alias Phoenix.Controller
  alias Plug.Conn

  @doc false
  @spec init(any()) :: any()
  def init(config), do: config

  @doc false
  @spec call(Conn.t(), atom() | binary() | [atom()] | [binary()]) :: Conn.t()
  def call(conn, roles) do
    token = conn.req_cookies["pikiri_auth_token"]
    case Pikiri.Guardian.resource_from_token(token) do
    {:ok, resource, claims} -> 
        has_role?(resource, roles) 
        |> maybe_halt(conn)
        |> assign_helpers(resource.role)
    {:error, error} -> 
        has_role?(nil, roles) |> maybe_halt(conn)
    end
  end

  defp has_role?(nil, _roles), do: false
  defp has_role?(user, roles) when is_list(roles), do: Enum.any?(roles, &has_role?(user, &1))
  defp has_role?(user, role) when is_atom(role), do: has_role?(user, Atom.to_string(role))
  defp has_role?(%{role: role}, role), do: true
  defp has_role?(_user, _role), do: false

  defp assign_helpers(conn, role) do
    conn
    |> assign(:is_admin?, role == "admin")
    |> assign(:is_contributor?, role == "contributor")
  end

  defp maybe_halt(true, conn), do: conn
  defp maybe_halt(_any, conn) do
    conn
    |> Controller.redirect(to: Routes.login_path(conn, :new))
    |> halt()
  end
end