defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller
  alias DiscussWeb.Router.Helpers, as: Routes
  alias Discuss.{Repo,Topic}

  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{})
    render conn, :new, changeset: changeset
  end

  def index(conn, _params) do
    topics = Repo.all(Topic)
    render conn, :index, topics: topics
  end

  def create(conn, %{"topic" => topic_params}) do
    # We use an empty record here because we are creating one here - would have included an id if we were updating an existing one
    result = %Topic{}
    |> Topic.changeset(topic_params)
    |> Repo.insert()

    # How routes differ now:
    # https://www.phoenixframework.org/blog/phoenix-1.7-final-released
    case result do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic created successfully.")
        |> redirect(to: ~p"/")

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Something went wrong when creating topic.")
        |> render(:new, changeset: changeset)

    end
  end
end