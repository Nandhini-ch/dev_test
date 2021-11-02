defmodule Inconn2Service.Ticket do
  @moduledoc """
  The Ticket context.
  """

  import Ecto.Query, warn: false
  alias Inconn2Service.Repo
  import Ecto.Changeset

  alias Inconn2Service.Ticket.WorkrequestCategory

  @doc """
  Returns the list of workrequest_categories.

  ## Examples

      iex> list_workrequest_categories()
      [%WorkrequestCategory{}, ...]

  """
  def list_workrequest_categories(prefix) do
    Repo.all(WorkrequestCategory, prefix: prefix)
  end

  @doc """
  Gets a single workrequest_category.

  Raises `Ecto.NoResultsError` if the Workrequest category does not exist.

  ## Examples

      iex> get_workrequest_category!(123)
      %WorkrequestCategory{}

      iex> get_workrequest_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_workrequest_category!(id, prefix), do: Repo.get!(WorkrequestCategory, id, prefix: prefix)

  @doc """
  Creates a workrequest_category.

  ## Examples

      iex> create_workrequest_category(%{field: value})
      {:ok, %WorkrequestCategory{}}

      iex> create_workrequest_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_workrequest_category(attrs \\ %{}, prefix) do
    %WorkrequestCategory{}
    |> WorkrequestCategory.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a workrequest_category.

  ## Examples

      iex> update_workrequest_category(workrequest_category, %{field: new_value})
      {:ok, %WorkrequestCategory{}}

      iex> update_workrequest_category(workrequest_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_workrequest_category(%WorkrequestCategory{} = workrequest_category, attrs, prefix) do
    workrequest_category
    |> WorkrequestCategory.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a workrequest_category.

  ## Examples

      iex> delete_workrequest_category(workrequest_category)
      {:ok, %WorkrequestCategory{}}

      iex> delete_workrequest_category(workrequest_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_workrequest_category(%WorkrequestCategory{} = workrequest_category, prefix) do
    Repo.delete(workrequest_category, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking workrequest_category changes.

  ## Examples

      iex> change_workrequest_category(workrequest_category)
      %Ecto.Changeset{data: %WorkrequestCategory{}}

  """
  def change_workrequest_category(%WorkrequestCategory{} = workrequest_category, attrs \\ %{}) do
    WorkrequestCategory.changeset(workrequest_category, attrs)
  end

  alias Inconn2Service.Ticket.WorkRequest


  @doc """
  Returns the list of work_requests.

  ## Examples

      iex> list_work_requests()
      [%WorkRequest{}, ...]

  """
  def list_work_requests(prefix) do
    Repo.all(WorkRequest, prefix: prefix)
  end

  @doc """
  Gets a single work_request.

  Raises `Ecto.NoResultsError` if the Work request does not exist.

  ## Examples

      iex> get_work_request!(123)
      %WorkRequest{}

      iex> get_work_request!(456)
      ** (Ecto.NoResultsError)

  """
  def get_work_request!(id, prefix), do: Repo.get!(WorkRequest, id, prefix: prefix)

  @doc """
  Creates a work_request.

  ## Examples

      iex> create_work_request(%{field: value})
      {:ok, %WorkRequest{}}

      iex> create_work_request(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_work_request(attrs \\ %{}, prefix, user \\ %{id: nil}) do
    payload = read_attachment(attrs)
    %WorkRequest{}
    |> WorkRequest.changeset(payload)
    |> attachment_format(attrs)
    |> requested_user_id(user)
    |> Repo.insert(prefix: prefix)
  end

  #defp read_attachment(%{"attachment" => ""} = attrs), do: attrs

  defp read_attachment(attrs) do
    attachment = Map.get(attrs, "attachment")
    if attachment != nil and attachment != "" do
      {:ok, attachment_binary} = File.read(attachment.path)
      Map.put(attrs, "attachment", attachment_binary)
    else
      attrs
    end
  end

  defp attachment_format(cs, attrs) do
    attachment = Map.get(attrs, "attachment")
    if attachment != nil and attachment != "" do
      change(cs, %{attachment_type: attachment.content_type})
    else
      cs
    end
  end

  def requested_user_id(cs, user) do
    change(cs, %{requested_user_id: user.id})
  end


  @doc """
  Updates a work_request.

  ## Examples

      iex> update_work_request(work_request, %{field: new_value})
      {:ok, %WorkRequest{}}

      iex> update_work_request(work_request, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_work_request(%WorkRequest{} = work_request, attrs, prefix) do
    payload = read_attachment(attrs)
    work_request
    |> WorkRequest.changeset(payload)
    |> attachment_format(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a work_request.

  ## Examples

      iex> delete_work_request(work_request)
      {:ok, %WorkRequest{}}

      iex> delete_work_request(work_request)
      {:error, %Ecto.Changeset{}}

  """
  def delete_work_request(%WorkRequest{} = work_request, prefix) do
    Repo.delete(work_request, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking work_request changes.

  ## Examples

      iex> change_work_request(work_request)
      %Ecto.Changeset{data: %WorkRequest{}}

  """
  def change_work_request(%WorkRequest{} = work_request, attrs \\ %{}) do
    WorkRequest.changeset(work_request, attrs)
  end
end
