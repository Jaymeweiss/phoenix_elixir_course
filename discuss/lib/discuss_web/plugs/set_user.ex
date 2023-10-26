defmodule DiscussWeb.Plugs.SetUser do
  import Plug.Conn
  import Phoenix.Controller

  alias Discuss.{Repo,User}

  def init(opts) do
    # useful to do expensive calculations here
    opts
  end

  # called anytime the plug runs
  # the _opts here is what is returned from the init function
  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    IO.inspect "SOMETHING ELSE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    # condition statement checks each condition specified
    cond do
      user = user_id && Repo.get(User, user_id) ->
        assign(conn, :user, user)
      true ->
        assign(conn, :user, nil)
    end
  end
end