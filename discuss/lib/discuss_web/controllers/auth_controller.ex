defmodule DiscussWeb.AuthController do
  use DiscussWeb, :controller
  alias Discuss.{Repo,User}
  plug Ueberauth

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    changeset = User.changeset(%User{}, %{email: auth.info.email, provider: to_string(auth.provider), token: auth.credentials.token})
     case insert_or_fetch_user(changeset) do
      {:ok, user} -> signin(conn, user)
      {:error, _changeset} -> handle_failure conn
    end
  end

  def signout(conn, _params) do

    conn
    |> configure_session(drop: true) # drops all of the session content - no trace of the user on the session
    |> put_flash(:info, "Signed out")
    |> redirect(to: ~p"/")
  end

  defp insert_or_fetch_user(changeset) do
    case Repo.get_by(User, email: changeset.changes.email) do
      nil -> Repo.insert(changeset)
      user -> {:ok, user}
    end
  end

  defp signin(conn, user) do
    conn
    |> put_flash(:info, "Welcome #{user.email}")
    |> put_session(:user_id, user.id)
    |> redirect(to: ~p"/")
  end

  defp handle_failure(conn) do
    conn
    |> put_flash(:error, "Error signing in")
    |> redirect(to: ~p"/")
  end

end