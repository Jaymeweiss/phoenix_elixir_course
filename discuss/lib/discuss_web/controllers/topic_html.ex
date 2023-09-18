defmodule DiscussWeb.TopicHTML do
  use DiscussWeb, :html
  import Phoenix.HTML.Form # Needed for form_for/4
  alias DiscussWeb.Router.Helpers, as: Routes

  embed_templates "topic_html/*"
end
