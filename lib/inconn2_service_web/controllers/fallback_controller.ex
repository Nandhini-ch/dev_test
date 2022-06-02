defmodule Inconn2ServiceWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use Inconn2ServiceWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(Inconn2ServiceWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  # Called when Triplex create failed
  def call(conn, {:error, {:triplex, err_msg}}) when is_binary(err_msg) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(Inconn2ServiceWeb.ChangesetView)
    |> render("error.json", triplex: err_msg)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(Inconn2ServiceWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:could_not_delete, msg}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(Inconn2ServiceWeb.ErrorView)
    |> render("error_delete.json", msg: msg)
  end

  def call(conn, {:deleted, _msg}), do: send_resp(conn, :no_content, "")

end
