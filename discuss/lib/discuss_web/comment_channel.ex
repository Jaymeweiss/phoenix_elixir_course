defmodule DiscussWeb.CommentChannel do
  use Phoenix.Channel
  alias Discuss.{Comment, Repo, Topic}

  def join("comments:" <> topic_id, _params, socket) do
    topic = Topic
            |> Repo.get!(String.to_integer(topic_id))
            |> Repo.preload(comments: [:user])

    {:ok, %{comments: topic.comments}, assign(socket, :topic, topic)}
  end

  def handle_in(name, %{"content" =>  content}, socket) do
    topic = socket.assigns.topic
    changeset = topic
                |> Ecto.build_assoc(:comments, user_id: socket.assigns.user_id)
                |> Comment.changeset(%{content: content})

    case Repo.insert(changeset) do
      {:ok, comment} ->
        broadcast! socket, "comments:#{topic.id}:new", %{comment: comment}
        {:reply, :ok, socket}
      {:error, _changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end
end