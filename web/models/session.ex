defmodule Cr2016site.Session do
  alias Cr2016site.User

  def login(params, repo) do
    user = repo.get_by(User, email: String.downcase(params["email"]))
    case authenticate(user, params["password"]) do
      true -> {:ok, user}
      _    -> :error
    end
  end

  defp authenticate(user, password) do
    case user do
      nil -> false
      _   -> Comeonin.Bcrypt.checkpw(password, user.crypted_password)
    end
  end

  def current_user(conn) do
    conn.assigns[:current_user_object]
  end

  def logged_in?(conn), do: !!current_user(conn)

  def admin?(conn), do: logged_in?(conn) && current_user(conn).admin
end
