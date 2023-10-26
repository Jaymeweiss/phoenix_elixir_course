defmodule DiscussWeb.Plugs.RequireAuth do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:user] do
      conn
    else
      conn
      |> put_flash(:error, "You must be signed in to do that")
      |> redirect(to: "/")
      |> halt() # wont return a conn - form the response and send to the user
    end
  end
end