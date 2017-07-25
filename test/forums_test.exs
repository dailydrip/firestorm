defmodule FirestormWeb.ForumsTest do
  use FirestormWeb.DataCase, async: false

  alias FirestormWeb.Forums
  alias FirestormWeb.Forums.{User, Category, Thread}

  @create_user_attrs %{email: "some email", name: "some name", username: "some username"}
  @update_user_attrs %{email: "some updated email", name: "some updated name", username: "some updated username"}
  @invalid_user_attrs %{email: nil, name: nil, username: nil}

  @create_category_attrs %{title: "some title"}
  @update_category_attrs %{title: "some updated title"}
  @invalid_category_attrs %{title: nil}

  @create_thread_attrs %{title: "some title", body: "some body"}
  @update_thread_attrs %{title: "some updated title"}
  @invalid_thread_attrs %{title: nil}

  def fixture(type, attrs \\ %{})
  def fixture(:user, attrs) do
    {:ok, user} = Forums.create_user(attrs)
    user
  end
  def fixture(:category, attrs) do
    {:ok, category} = Forums.create_category(attrs)
    category
  end

  def fixture(:thread, category, user, attrs) do
    {:ok, thread} = Forums.create_thread(category, user, attrs)
    thread
  end

  def fixture(:post, thread, user, attrs) do
    {:ok, post} = Forums.create_post(thread, user, attrs)
    post
  end

  test "list_users/1 returns all users" do
    user = fixture(:user, @create_user_attrs)
    assert Forums.list_users() == [user]
  end

  test "get_user! returns the user with given id" do
    user = fixture(:user, @create_user_attrs)
    assert Forums.get_user!(user.id) == user
  end

  test "create_user/1 with valid data creates a user" do
    assert {:ok, %User{} = user} = Forums.create_user(@create_user_attrs)
    assert user.email == "some email"
    assert user.name == "some name"
    assert user.username == "some username"
  end

  test "create_user/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Forums.create_user(@invalid_user_attrs)
  end

  test "update_user/2 with valid data updates the user" do
    user = fixture(:user, @create_user_attrs)
    assert {:ok, user} = Forums.update_user(user, @update_user_attrs)
    assert %User{} = user
    assert user.email == "some updated email"
    assert user.name == "some updated name"
    assert user.username == "some updated username"
  end

  test "update_user/2 with invalid data returns error changeset" do
    user = fixture(:user, @create_user_attrs)
    assert {:error, %Ecto.Changeset{}} = Forums.update_user(user, @invalid_user_attrs)
    assert user == Forums.get_user!(user.id)
  end

  test "delete_user/1 deletes the user" do
    user = fixture(:user, @create_user_attrs)
    assert {:ok, %User{}} = Forums.delete_user(user)
    assert_raise Ecto.NoResultsError, fn -> Forums.get_user!(user.id) end
  end

  test "change_user/1 returns a user changeset" do
    user = fixture(:user, @create_user_attrs)
    assert %Ecto.Changeset{} = Forums.change_user(user)
  end

  test "list_categories/1 returns all categories" do
    category = fixture(:category, @create_category_attrs)
    assert Forums.list_categories() == [category]
  end

  test "get_category! returns the category with given id" do
    category = fixture(:category, @create_category_attrs)
    assert Forums.get_category!(category.id) == category
  end

  test "create_category/1 with valid data creates a category" do
    assert {:ok, %Category{} = category} = Forums.create_category(@create_category_attrs)
    assert category.title == "some title"
  end

  test "create_category/1 automatically generates a slug" do
    assert {:ok, %Category{} = category} = Forums.create_category(@create_category_attrs)
    assert category.slug == "some-title"
    assert {:ok, %Category{} = category} = Forums.create_category(@create_category_attrs)
    assert category.slug == "some-title-1"
  end

  test "create_category/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Forums.create_category(@invalid_category_attrs)
  end

  test "update_category/2 with valid data updates the category" do
    category = fixture(:category, @create_category_attrs)
    assert {:ok, category} = Forums.update_category(category, @update_category_attrs)
    assert %Category{} = category
    assert category.title == "some updated title"
  end

  test "update_category/2 with invalid data returns error changeset" do
    category = fixture(:category, @create_category_attrs)
    assert {:error, %Ecto.Changeset{}} = Forums.update_category(category, @invalid_category_attrs)
    assert category == Forums.get_category!(category.id)
  end

  test "delete_category/1 deletes the category" do
    category = fixture(:category, @create_category_attrs)
    assert {:ok, %Category{}} = Forums.delete_category(category)
    assert_raise Ecto.NoResultsError, fn -> Forums.get_category!(category.id) end
  end

  test "change_category/1 returns a category changeset" do
    category = fixture(:category, @create_category_attrs)
    assert %Ecto.Changeset{} = Forums.change_category(category)
  end

  describe "threads" do
    setup [:create_user, :create_category]

    test "list_threads/1 returns all threads", %{category: category, user: user} do
      thread = fixture(:thread, category, user, @create_thread_attrs)
      expected = [thread.title]
      result =
        category
        |> Forums.list_threads
        |> Enum.map(&(&1.title))

      assert expected == result
    end

  test "recent_threads/1 returns a category's threads ordered by most recent post", %{category: category, user: user} do
    threads =
      for num <- ~w(First Second Third Fourth Fifth) do
        fixture(:thread, category, user, %{title: "#{num} thread", body: "#{num} thread body"})
      end
    for thread <- threads do
      for n <- [2, 3, 4] do
        fixture(:post, thread, user, %{body: "Post #{n} in #{thread.title}"})
      end
    end
    [thread1, thread2, thread3, thread4, thread5] = threads
    :timer.sleep 1
    fixture(:post, thread1, user, %{body: "last post in thread1"})
    fixture(:post, thread3, user, %{body: "last post in thread2"})
    fixture(:post, thread5, user, %{body: "last post in thread3"})
    other_category = fixture(:category, %{title: "other category"})
    other_thread = fixture(:thread, other_category, user, %{title: "other thread", body: "other thread body"})
    _other_thread_post = fixture(:post, other_thread, user, %{body: "Other thread last post"})

    recent_threads =
      category
      |> Forums.recent_threads()

    thread_ids =
      recent_threads
      |> Enum.map(&(&1.id))

    expected_ids = [thread5.id, thread3.id, thread1.id, thread4.id, thread2.id]
    assert expected_ids == thread_ids
  end

    test "get_thread! returns the thread with given id", %{category: category, user: user} do
      thread = fixture(:thread, category, user, @create_thread_attrs)
      assert Forums.get_thread!(category, thread.id).title == thread.title
    end

    test "create_thread/2 with valid data creates a thread and its first post", %{category: category, user: user} do
      assert {:ok, %Thread{} = thread} = Forums.create_thread(category, user, @create_thread_attrs)
      assert thread.title == "some title"
      first_post = hd(thread.posts)
      assert first_post.thread_id == thread.id
      assert first_post.body == "some body"
    end

    test "create_thread/1 with invalid data returns error changeset", %{category: category, user: user} do
      assert {:error, %Ecto.Changeset{}} = Forums.create_thread(category, user, @invalid_thread_attrs)
    end

    test "create_thread/2 automatically generates a slug", %{category: category, user: user} do
      assert {:ok, %Thread{} = thread} = Forums.create_thread(category, user, @create_thread_attrs)
      assert thread.slug == "some-title"
      assert {:ok, %Thread{} = thread} = Forums.create_thread(category, user, @create_thread_attrs)
      assert thread.slug == "some-title-1"
    end

    test "update_thread/2 with valid data updates the thread", %{category: category, user: user} do
      thread = fixture(:thread, category, user, @create_thread_attrs)
      assert {:ok, thread} = Forums.update_thread(thread, @update_thread_attrs)
      assert %Thread{} = thread
      assert thread.title == "some updated title"
    end

    test "update_thread/2 with invalid data returns error changeset", %{category: category, user: user} do
      thread = fixture(:thread, category, user, @create_thread_attrs)
      assert {:error, %Ecto.Changeset{}} = Forums.update_thread(thread, @invalid_thread_attrs)
      assert thread.title == Forums.get_thread!(category, thread.id).title
    end

    test "delete_thread/1 deletes the thread", %{category: category, user: user} do
      thread = fixture(:thread, category, user, @create_thread_attrs)
      assert {:ok, %Thread{}} = Forums.delete_thread(thread)
      assert_raise Ecto.NoResultsError, fn -> Forums.get_thread!(category, thread.id) end
    end

    test "change_thread/1 returns a thread changeset", %{category: category, user: user} do
      thread = fixture(:thread, category, user, @create_thread_attrs)
      assert %Ecto.Changeset{} = Forums.change_thread(thread)
    end
  end

  test "get_user_by_username/1 returns an existing user" do
    user = fixture(:user, @create_user_attrs)
    assert user == Forums.get_user_by_username(user.username)
  end

  describe "login_or_register_from_github/1 returns a user after creating one" do
    test "when the user has name and public email on GitHub" do
      auth_info = %{
        name: "Josh Adams",
        nickname: "knewter",
        email: "josh@dailydrip.com"
      }
      result = Forums.login_or_register_from_github(auth_info)
      assert {:ok, user} = result
      assert user.email == "josh@dailydrip.com"
    end

    test "when the user doesn't have name and public email on GitHub" do
      auth_info = %{
        name: nil,
        nickname: "knewter",
        email: nil,
      }
      result = Forums.login_or_register_from_github(auth_info)
      assert {:ok, user} = result
      assert user.name == "knewter"
      assert user.email == "knewter@users.noreply.github.com"
    end
  end

  test "login_or_register_from_github/1 returns a user if it already exists" do
    auth_info = %{
      name: "Josh Adams",
      nickname: "knewter",
      email: "josh@dailydrip.com"
    }
    Forums.login_or_register_from_github(auth_info)
    result = Forums.login_or_register_from_github(auth_info)
    assert {:ok, user} = result
    assert user.email == "josh@dailydrip.com"
  end

  describe "posting in a thread" do
    setup [:create_user, :create_category, :create_thread]

    test "creating a post in a thread", %{thread: thread, user: user} do
      {:ok, post} = Forums.create_post(thread, user, %{body: "Some body"})
      assert post.thread_id == thread.id
      assert post.user_id == user.id
      assert post.body == "Some body"
    end
  end

  describe "watching a thread" do
    setup [:create_user, :create_category, :create_thread]

    test "watching a thread", %{thread: thread, user: user} do
      {:ok, _watch} = user |> Forums.watch(thread)
      assert thread |> Forums.watched_by?(user)
    end
  end

  describe "viewing a post" do
    setup [:create_user, :create_category, :create_thread]

    test "viewing a post", %{thread: thread, user: user} do
      thread =
        thread
        |> Repo.preload(:posts)

      [first_post] = thread.posts

      {:ok, _view} = user |> Forums.view(first_post)
      assert first_post |> Forums.viewed_by?(user)
    end
  end

  def create_category(_) do
    category = fixture(:category, @create_category_attrs)
    {:ok, category: category}
  end
  def create_thread(%{category: category, user: user}) do
    thread = fixture(:thread, category, user, @create_thread_attrs)
    {:ok, thread: thread}
  end
  def create_user(_) do
    user = fixture(:user, @create_user_attrs)
    {:ok, user: user}
  end
end
