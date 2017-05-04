defmodule FirestormWeb.Web.ThreadView do
  use FirestormWeb.Web, :view
  alias FirestormData.Thread
  alias FirestormWeb.Markdown
  import FirestormWeb.Web.SlugHelpers

  def user(thread) do
    {:ok, user} = Thread.user(thread)
    user
  end

  def markdown(body) do
    body
    |> Markdown.render
    |> raw
  end

  def back("show.html", conn) do
    category = conn.assigns[:category]
    category_path(conn, :show, category_finder(category))
  end
  def back(_template, _conn), do: nil

  def post_class(post, first_unread_post) do
    if post.id == first_unread_post.id do
      "first-unread"
    else
      ""
    end
  end
end
