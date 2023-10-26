defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller
  alias Discuss.{Repo,Topic}
  import Ecto

  plug DiscussWeb.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]
  plug :check_topic_owner when action in [:edit, :update, :delete]

  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{})
    render conn, :new, changeset: changeset
  end

  def index(conn, _params) do
    topics = Repo.all(Topic)
    render conn, :index, topics: topics
  end

  def create(conn, %{"topic" => topic_params}) do
    result = conn.assigns.user
      |> build_assoc(:topics) # produces a topic struct with the user_id set - we should not set the id manually
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

  def edit(conn, %{"id" => id}) do
    topic = Repo.get(Topic, id)
    changeset = Topic.changeset(topic)
    render conn, :edit, topic: topic, changeset: changeset
  end

  def update(conn, %{"id" => id, "topic" => topic_params}) do
    topic = Repo.get(Topic, id)
    changeset = Topic.changeset(topic, topic_params)

    case Repo.update(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic updated successfully.")
        |> redirect(to: ~p"/")

      {:error, changeset} ->
        render conn, :edit, topic: topic, changeset: changeset
    end
  end

  def delete(conn, %{"id" => id}) do
    Repo.get!(Topic, id) |> Repo.delete! # Bang version of the delete function will raise an error if the record is not found
    conn
    |> put_flash(:info, "Topic deleted successfully.")
    |> redirect(to: ~p"/")
  end

  def check_topic_owner(%{params: %{"id" => id}} = conn, _params) do
    topic = Repo.get(Topic, id)
    if topic.user_id != conn.assigns.user.id do
      conn
      |> put_flash(:error, "You are not authorized to do that")
      |> redirect(to: ~p"/")
      |> halt()
    else
      conn
    end
  end
end