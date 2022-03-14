defmodule Inconn2Service.Ticket do
  @moduledoc """
  The Ticket context.
  """

  import Ecto.Query, warn: false
  alias Inconn2Service.Repo
  import Ecto.Changeset

  alias Inconn2Service.Ticket.{WorkrequestCategory, WorkrequestStatusTrack}
  alias Inconn2Service.Staff.User
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.AssetConfig.Site

  @doc """
  Returns the list of workrequest_categories.

  ## Examples

      iex> list_workrequest_categories()
      [%WorkrequestCategory{}, ...]

  """
  def list_workrequest_categories(prefix) do
    Repo.all(WorkrequestCategory, prefix: prefix) |> Repo.preload(:workrequest_subcategories)
  end

  def list_workrequest_categories(query_params, prefix) do
    WorkrequestCategory
    |> Repo.add_active_filter(query_params)
    |> Repo.all(prefix: prefix)
  end

  def list_workrequest_categories_with_helpdesk_user(prefix) do
    WorkrequestCategory
    |> Repo.all(prefix: prefix)
    |> get_helpdesk_user_for_categories(prefix)
  end

  def get_helpdesk_user_for_categories(categories, prefix) do
    Enum.map(categories, fn c ->
      helpdesk_users = Inconn2Service.Ticket.CategoryHelpdesk |> where([workrequest_category_id: ^c.id]) |> Repo.all(prefix: prefix)
      users = Enum.map(helpdesk_users, fn h -> Inconn2Service.Staff.get_user!(h.user_id, prefix) end)
      Map.put_new(c, :users, users)
    end)
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
  def get_workrequest_category!(id, prefix), do: Repo.get!(WorkrequestCategory, id, prefix: prefix) |> Repo.preload(:workrequest_subcategories)

  @doc """
  Creates a workrequest_category.

  ## Examples

      iex> create_workrequest_category(%{field: value})
      {:ok, %WorkrequestCategory{}}

      iex> create_workrequest_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_workrequest_category(attrs \\ %{}, prefix) do
    result = %WorkrequestCategory{}
              |> WorkrequestCategory.changeset(attrs)
              |> Repo.insert(prefix: prefix)

    case result do
      {:ok, workrequest_category} -> {:ok, workrequest_category |> Repo.preload(:workrequest_subcategories)}
      _ -> result
    end

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
    result = workrequest_category
             |> WorkrequestCategory.changeset(attrs)
             |> Repo.update(prefix: prefix)
    case result do
      {:ok, workrequest_category} -> {:ok, workrequest_category |> Repo.preload(:workrequest_subcategories, force: true)}
      _ -> result
    end
  end

  def update_active_status_for_workrequest_category(%WorkrequestCategory{} = workrequest_category, attrs, prefix) do
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

  alias Inconn2Service.Ticket.CategoryHelpdesk
  alias Inconn2Service.Ticket.WorkRequest


  @doc """
  Returns the list of work_requests.

  ## Examples

      iex> list_work_requests()
      [%WorkRequest{}, ...]

  """
  def list_work_requests(prefix) do
    Repo.all(WorkRequest, prefix: prefix) |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])
  end

  def list_work_requests_for_actions(user, prefix) do
    %{
      raised_by_me: list_work_requests_for_raised_user(user, prefix),
      to_be_closed: list_work_requests_acknowledgement(user, prefix),
      helpdesk: list_work_requests_for_helpdesk_user(user, prefix)
    }
  end

  def list_work_requests_for_raised_user(user, prefix) do
    WorkRequest |> where([requested_user_id: ^user.id]) |> Repo.all(prefix: prefix) |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])
  end

  def list_work_requests_for_assigned_user(user, prefix) do
    WorkRequest |> where([assigned_user_id: ^user.id]) |> Repo.all(prefix: prefix) |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])
  end

  def list_work_requests_acknowledgement(user, prefix) do
    WorkRequest |> where([requested_user_id: ^user.id, status: "CP"]) |> Repo.all(prefix: prefix) |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])
  end

  def list_work_requests_for_user_by_qr(qr_string, user, prefix) do
    [asset_type, uuid] = String.split(qr_string, ":")
    case asset_type do
      "L" ->
        location = Inconn2Service.AssetConfig.get_location_by_qr_code(uuid, prefix)
        WorkRequest
        |> where([asset_id: ^location.id, assigned_user_id: ^user.id])
        |> Repo.all(prefix: prefix)
        |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])

      "E" ->
        equipment = Inconn2Service.AssetConfig.get_equipment_by_qr_code(uuid, prefix)
        WorkRequest
        |> where([asset_id: ^equipment.id, assigned_user_id: ^user.id])
        |> Repo.all(prefix: prefix)
        |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])
    end
  end

  def list_work_requests_for_approval(current_user, prefix) do
    query = from w in WorkRequest, where: ^current_user.id in w.approvals_required
    Repo.all(query, prefix: prefix) |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])
  end

  def list_work_requests_for_helpdesk_user(current_user, prefix) do
    helpdesk = get_category_helpdesk_by_user(current_user.id, prefix)
    if helpdesk != [] do
      workrequest_category_ids = Enum.map(helpdesk, fn x -> x.workrequest_category_id end)
      from(wr in WorkRequest, where: wr.workrequest_category_id in ^workrequest_category_ids and wr.status != "CS")
      |> Repo.all(prefix: prefix)
      |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])
    else
      []
    end
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
                                          |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])

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
    created_work_request = %WorkRequest{}
    |> WorkRequest.changeset(payload)
    |> auto_fill_wr_category(prefix)
    |> validate_asset_id(prefix)
    |> attachment_format(attrs)
    |> requested_user_id(user)
    |> validate_assigned_user_id(prefix)
    |> Repo.insert(prefix: prefix)

    case created_work_request do
      {:ok, work_request} ->
        create_status_track(work_request, prefix)
        {:ok, work_request |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])}

      _ ->
        created_work_request

    end
  end

  defp auto_fill_wr_category(cs, prefix) do
    wr_sbc_id = get_change(cs, :workrequest_subcategory_id)
    if wr_sbc_id != nil do
      wr_subcategory = get_workrequest_subcategory(wr_sbc_id, prefix)
      case wr_subcategory do
        nil -> cs
        _ -> change(cs, %{workrequest_category_id: wr_subcategory.workrequest_category_id})
      end
    else
      cs
    end
  end

  defp validate_asset_id(cs, prefix) do
    asset_type = get_change(cs, :asset_type)
    asset_id = get_change(cs, :asset_id)
    if asset_type in ["L", "E"] and asset_id != nil do
      case asset_type do
        "L" ->
          case AssetConfig.get_location(asset_id, prefix) do
            nil -> add_error(cs, :asset_id, "Asset ID is invalid")
            _ -> cs
          end
        "E" ->
          case AssetConfig.get_location(asset_id, prefix) do
            nil -> add_error(cs, :asset_id, "Asset ID is invalid")
            _ -> cs
          end
        end
      else
        cs
      end
  end

  defp get_date_time_in_required_time_zone(work_request, prefix) do
    site = Repo.get!(Site, work_request.site_id, prefix: prefix)
    date_time = DateTime.now!(site.time_zone)
    {Date.new!(date_time.year, date_time.month, date_time.day), Time.new!(date_time.hour, date_time.minute, date_time.second)}
  end

  defp create_status_track(work_request, prefix) do
    {date, time} = get_date_time_in_required_time_zone(work_request, prefix)
    workrequest_status_track = %{
      "work_request_id" => work_request.id,
      "status_update_date" => date,
      "status_update_time" => time,
      "status" => "RS"
    }
    create_workrequest_status_track(workrequest_status_track, prefix)
    {:ok, work_request}
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

  defp requested_user_id(cs, user) do
    change(cs, %{requested_user_id: user.id})
  end

  defp validate_assigned_user_id(cs, prefix) do
    as_user_id = get_change(cs, :assigned_user_id, nil)
    if as_user_id != nil do
      case Repo.get(User, as_user_id, prefix: prefix) do
        nil -> add_error(cs, :assigned_user_id, "Assigned User Id is invalid")
        _ ->  change(cs, %{status: "AS"})
              cs
      end
    else
      cs
    end
  end
  @doc """
  Updates a work_request.

  ## Examples

      iex> update_work_request(work_request, %{field: new_value})
      {:ok, %WorkRequest{}}

      iex> update_work_request(work_request, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_work_request(%WorkRequest{} = work_request, attrs, prefix, user \\ %{id: nil}) do
    payload = read_attachment(attrs)
    # wr_status =  change_work_request(work_request, attrs) |> get_field(:status, nil)
    updated_work_request = work_request
    |> WorkRequest.changeset(payload)
    |> auto_fill_wr_category(prefix)
    |> validate_asset_id(prefix)
    |> attachment_format(attrs)
    |> validate_assigned_user_id(prefix)
    |> validate_approvals_required_ids(prefix)
    |> is_approvals_required(user, prefix)
    |> calculate_tat(work_request, prefix)
    |> Repo.update(prefix: prefix)

    case updated_work_request do
      {:ok, work_request} ->
        update_status_track(work_request, prefix)
        {:ok, work_request |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee], force: true)}
      _ ->
        updated_work_request

    end

  end

  def update_work_requests(work_request_changes, prefix, user) do
    Enum.map(work_request_changes["ids"], fn id ->
      work_request = get_work_request!(id, prefix)
      {:ok, work_request} = update_work_request(work_request, Map.drop(work_request_changes, ["ids"]), prefix, user)
      work_request
    end)
  end

  # defp create_workorder_from_ticket(work_request, user, prefix, "AS") do
  #   {:ok, work_request}
  # end

  # defp create_workorder_from_ticket(work_request, _user, _prefix, _) do
  #   {:ok, work_request}
  # end

  defp calculate_tat(cs, work_request, prefix) do
    status = get_change(cs, :status)
    if status != nil do
      raised_dt = get_field(cs, :raised_date_time)
      site_dt = get_site_date_time(work_request, prefix)
      case status do
        "AS" ->
            tat = NaiveDateTime.diff(site_dt, raised_dt) / 60
            change(cs, %{response_tat: tat})
        "CP" ->
            tat = NaiveDateTime.diff(site_dt, raised_dt) / 60
              change(cs, %{resolution_tat: tat})
          _ ->
            cs
      end
    else
      cs
    end
  end

  defp get_site_date_time(work_request, prefix) do
    site = Repo.get!(Site, work_request.site_id, prefix: prefix)
    date_time = DateTime.now!(site.time_zone)
    NaiveDateTime.new!(date_time.year, date_time.month, date_time.day, date_time.hour, date_time.minute, date_time.second)
  end

  defp update_status_track(work_request, prefix) do
    case Repo.get_by(WorkrequestStatusTrack, [work_request_id: work_request.id, status: work_request.status], prefix: prefix) do
      nil ->
        {date, time} = get_date_time_in_required_time_zone(work_request, prefix)
        workrequest_status_track = %{
          "work_request_id" => work_request.id,
          "status_update_date" => date,
          "status_update_time" => time,
          "status" => work_request.status
        }
        create_workrequest_status_track(workrequest_status_track, prefix)
        {:ok, work_request |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])}

      _ ->
        {:ok, work_request |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])}

    end
  end

  defp validate_approvals_required_ids(cs, prefix) do
    user_ids = get_change(cs, :approvals_required, nil)
    if user_ids != nil do
      users = from(u in User, where: u.id in ^user_ids )
              |> Repo.all(prefix: prefix)
      case length(user_ids) == length(users) do
        true -> cs
        false -> add_error(cs, :approvals_required, "User IDs are invalid")
      end
    else
      cs
    end
  end

  defp is_approvals_required(cs, user, prefix) do
    site_id = get_field(cs, :site_id)
    category_id = get_field(cs, :workrequest_category_id)
    helpdesks = CategoryHelpdesk
                |> where(site_id: ^site_id)
                |> where(workrequest_category_id: ^category_id)
                |> Repo.all(prefix: prefix)
    helpdesk_users = Enum.map(helpdesks, fn helpdesk -> helpdesk.user_id end)
    if user.id in helpdesk_users do
      validate_required(cs, :is_approvals_required)
    else
      cs
    end
  end

  # defp approval(cs) do
  #   case get_field(cs, :is_approvals_required) do
  #     true ->
  #           if get_field(cs, :rejected_user_ids, []) == [] do
  #             approved(cs)
  #           else
  #             rejected(cs)
  #           end
  #     _ -> cs
  #   end
  # end

  # defp approved(cs) do
  #   all_users = MapSet.new(get_field(cs, :approvals_required, []))
  #   approved_users = MapSet.new(get_field(cs, :approved_user_ids, []))
  #   if all_users == approved_users do
  #     change(cs, %{status: "AP"})
  #   else
  #     cs
  #   end
  # end

  # defp rejected(cs) do
  #   all_users = MapSet.new(get_field(cs, :approvals_required, []))
  #   approved_users = MapSet.new(get_field(cs, :approved_user_ids, []))
  #   rejected_users = MapSet.new(get_field(cs, :rejected_user_ids, []))
  #   if all_users == MapSet.union(approved_users, rejected_users) do
  #     change(cs, %{status: "RJ"})
  #   else
  #     cs
  #   end
  # end
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


  @doc """
  Returns the list of category_helpdesks.

  ## Examples

      iex> list_category_helpdesks()
      [%CategoryHelpdesk{}, ...]

  """
  def list_category_helpdesks(prefix) do
    Repo.all(CategoryHelpdesk, prefix: prefix) |> Repo.preload([:site, workrequest_category: :workrequest_subcategories])
  end

  @doc """
  Gets a single category_helpdesk.

  Raises `Ecto.NoResultsError` if the Category helpdesk does not exist.

  ## Examples

      iex> get_category_helpdesk!(123)
      %CategoryHelpdesk{}

      iex> get_category_helpdesk!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category_helpdesk!(id, prefix), do: Repo.get!(CategoryHelpdesk, id, prefix: prefix) |> Repo.preload([:site, workrequest_category: :workrequest_subcategories])
  def get_category_helpdesk_by_user(user_id, prefix) do
    CategoryHelpdesk
    |> where(user_id: ^user_id)
    |> Repo.all(prefix: prefix)
  end
  @doc """
  Creates a category_helpdesk.

  ## Examples

      iex> create_category_helpdesk(%{field: value})
      {:ok, %CategoryHelpdesk{}}

      iex> create_category_helpdesk(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category_helpdesk(attrs \\ %{}, prefix) do
    result = %CategoryHelpdesk{}
              |> CategoryHelpdesk.changeset(attrs)
              |> validate_user_id(prefix)
              |> Repo.insert(prefix: prefix)
    case result do
      {:ok, category_helpdesk} -> {:ok, category_helpdesk |> Repo.preload([:site, workrequest_category: :workrequest_subcategories])}
       _ -> result
    end
  end

  defp validate_user_id(cs, prefix) do
    user_id = get_field(cs, :user_id, nil)
    if user_id != nil do
      case Repo.get(User, user_id, prefix: prefix) do
        nil ->
          add_error(cs, :user_id, "User should exist")

        _ ->
          cs
      end
    else
      cs
    end
  end

  @doc """
  Updates a category_helpdesk.

  ## Examples

      iex> update_category_helpdesk(category_helpdesk, %{field: new_value})
      {:ok, %CategoryHelpdesk{}}

      iex> update_category_helpdesk(category_helpdesk, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category_helpdesk(%CategoryHelpdesk{} = category_helpdesk, attrs, prefix) do
    result = category_helpdesk
              |> CategoryHelpdesk.changeset(attrs)
              |> validate_user_id(prefix)
              |> Repo.update(prefix: prefix)
    case result do
      {:ok, category_helpdesk} -> {:ok, category_helpdesk |> Repo.preload([:site, workrequest_category: :workrequest_subcategories], force: true)}
      _ -> result
    end
  end

  @doc """
  Deletes a category_helpdesk.

  ## Examples

      iex> delete_category_helpdesk(category_helpdesk)
      {:ok, %CategoryHelpdesk{}}

      iex> delete_category_helpdesk(category_helpdesk)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category_helpdesk(%CategoryHelpdesk{} = category_helpdesk, prefix) do
    Repo.delete(category_helpdesk, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category_helpdesk changes.

  ## Examples

      iex> change_category_helpdesk(category_helpdesk)
      %Ecto.Changeset{data: %CategoryHelpdesk{}}

  """
  def change_category_helpdesk(%CategoryHelpdesk{} = category_helpdesk, attrs \\ %{}) do
    CategoryHelpdesk.changeset(category_helpdesk, attrs)
  end

  alias Inconn2Service.Ticket.WorkrequestStatusTrack

  @doc """
  Returns the list of workrequest_status_track.

  ## Examples

      iex> list_workrequest_status_track()
      [%WorkrequestStatusTrack{}, ...]

  """
  def list_workrequest_status_track(prefix) do
    Repo.all(WorkrequestStatusTrack, prefix: prefix)
  end

  def list_workrequest_status_track_for_work_request(work_request_id, prefix) do
    WorkrequestStatusTrack
    |> where(work_request_id: ^work_request_id)
    |> Repo.all(prefix: prefix)
  end

  @doc """
  Gets a single workrequest_status_track.

  Raises `Ecto.NoResultsError` if the Workrequest status track does not exist.

  ## Examples

      iex> get_workrequest_status_track!(123)
      %WorkrequestStatusTrack{}

      iex> get_workrequest_status_track!(456)
      ** (Ecto.NoResultsError)

  """
  def get_workrequest_status_track!(id, prefix), do: Repo.get!(WorkrequestStatusTrack, id, prefix: prefix)

  @doc """
  Creates a workrequest_status_track.

  ## Examples

      iex> create_workrequest_status_track(%{field: value})
      {:ok, %WorkrequestStatusTrack{}}

      iex> create_workrequest_status_track(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_workrequest_status_track(attrs \\ %{}, prefix) do
    %WorkrequestStatusTrack{}
    |> WorkrequestStatusTrack.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a workrequest_status_track.

  ## Examples

      iex> update_workrequest_status_track(workrequest_status_track, %{field: new_value})
      {:ok, %WorkrequestStatusTrack{}}

      iex> update_workrequest_status_track(workrequest_status_track, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_workrequest_status_track(%WorkrequestStatusTrack{} = workrequest_status_track, attrs, prefix) do
    workrequest_status_track
    |> WorkrequestStatusTrack.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a workrequest_status_track.

  ## Examples

      iex> delete_workrequest_status_track(workrequest_status_track)
      {:ok, %WorkrequestStatusTrack{}}

      iex> delete_workrequest_status_track(workrequest_status_track)
      {:error, %Ecto.Changeset{}}

  """
  def delete_workrequest_status_track(%WorkrequestStatusTrack{} = workrequest_status_track, prefix) do
    Repo.delete(workrequest_status_track, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking workrequest_status_track changes.

  ## Examples

      iex> change_workrequest_status_track(workrequest_status_track)
      %Ecto.Changeset{data: %WorkrequestStatusTrack{}}

  """
  def change_workrequest_status_track(%WorkrequestStatusTrack{} = workrequest_status_track, attrs \\ %{}) do
    WorkrequestStatusTrack.changeset(workrequest_status_track, attrs)
  end

  alias Inconn2Service.Ticket.Approval

  @doc """
  Returns the list of approvals.

  ## Examples

      iex> list_approvals()
      [%Approval{}, ...]

  """
  def list_approvals(prefix) do
    Repo.all(Approval, prefix: prefix) |> Repo.preload([:work_request, :user])
  end

  def list_approvals_for_work_order(work_request_id, prefix) do
    Approval
    |> where(work_request_id: ^work_request_id)
    |> Repo.all(prefix: prefix)
    |> Repo.preload([:work_request, :user])
  end

  @doc """
  Gets a single approval.

  Raises `Ecto.NoResultsError` if the Approval does not exist.

  ## Examples

      iex> get_approval!(123)
      %Approval{}

      iex> get_approval!(456)
      ** (Ecto.NoResultsError)

  """
  def get_approval!(id, prefix), do: Repo.get!(Approval, id, prefix: prefix) |> Repo.preload([:work_request, :user])

  @doc """
  Creates a approval.

  ## Examples

      iex> create_approval(%{field: value})
      {:ok, %Approval{}}

      iex> create_approval(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_approval(attrs \\ %{}, prefix, _user) do
    # IO.inspect(attrs)
    result = %Approval{}
              |> Approval.changeset(attrs)
              # |> set_approver_user_id(user)
              |> Repo.insert(prefix: prefix)

    update_status_for_work_request(result, prefix)
  end


  def create_multiple_approval(attrs, prefix, user) do
    Enum.map(attrs["work_request_ids"], fn id ->
      to_be_inserted = %{
        "approved" => attrs["approved"],
        "remarks" => attrs["remarks"],
        "user_id" => user.id,
        "work_request_id" => id,
        "action_at" => attrs["action_at"]
      }
      result = create_approval(to_be_inserted, prefix, user)
      IO.inspect(to_be_inserted)
      IO.inspect(result)
    end)

    %{success: true}
  end

  defp set_approver_user_id(cs, user) do
    change(cs, %{user_id: user.id})
  end

  def update_status_for_work_request({:error, reason}, _),  do: {:error, reason}

  def update_status_for_work_request({:ok, approval}, prefix) do
    approvals = Approval |> where(work_request_id: ^approval.work_request_id) |> Repo.all(prefix: prefix)
    work_request = Repo.get(WorkRequest, approval.work_request_id, prefix: prefix)
    IO.inspect(work_request)
    comparison_result = compare_length(length(approvals), length(work_request.approvals_required))
    case comparison_result do
      {:ok, _} ->
        approved = Enum.filter(approvals, fn a -> a.approved == true end)
        if length(approvals) == length(approved) do
          update_work_request(work_request, %{"status" => "AP"}, prefix)
        else
          update_work_request(work_request, %{"status" => "RJ"}, prefix)
        end
        {:ok, approval |> Repo.preload([:work_request, :user])}

      _ ->
        {:ok, approval |> Repo.preload([:work_request, :user])}
    end
  end

  def compare_length(num1, num2) when num1 == num2, do: {:ok, "equal"}
  def compare_length(_num1, _num2), do: {:error, "not_equal"}

  @doc """
  Updates a approval.

  ## Examples

      iex> update_approval(approval, %{field: new_value})
      {:ok, %Approval{}}

      iex> update_approval(approval, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_approval(%Approval{} = approval, attrs, prefix, user) do
    result = approval
              |> Approval.changeset(attrs)
              |> set_approver_user_id(user)
              |> Repo.update(prefix: prefix)
    update_status_for_work_request(result, prefix)
  end

  @doc """
  Deletes a approval.

  ## Examples

      iex> delete_approval(approval)
      {:ok, %Approval{}}

      iex> delete_approval(approval)
      {:error, %Ecto.Changeset{}}

  """
  def delete_approval(%Approval{} = approval, prefix) do
    Repo.delete(approval, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking approval changes.

  ## Examples

      iex> change_approval(approval)
      %Ecto.Changeset{data: %Approval{}}

  """
  def change_approval(%Approval{} = approval, attrs \\ %{}) do
    Approval.changeset(approval, attrs)
  end

  alias Inconn2Service.Ticket.WorkrequestSubcategory

  @doc """
  Returns the list of workrequest_subcategories.

  ## Examples

      iex> list_workrequest_subcategories()
      [%WorkrequestSubcategory{}, ...]

  """
  # def list_workrequest_subcategories(prefix) do
  #   Repo.all(WorkrequestSubcategory, prefix: prefix)
  # end

  def list_workrequest_subcategories_for_category(workrequest_category_id, prefix) do
    WorkrequestSubcategory
    |> where(workrequest_category_id: ^workrequest_category_id)
    |> Repo.all(prefix: prefix)

  end

  @doc """
  Gets a single workrequest_subcategory.

  Raises `Ecto.NoResultsError` if the Workrequest subcategory does not exist.

  ## Examples

      iex> get_workrequest_subcategory!(123)
      %WorkrequestSubcategory{}

      iex> get_workrequest_subcategory!(456)
      ** (Ecto.NoResultsError)

  """
  def get_workrequest_subcategory!(id, prefix), do: Repo.get!(WorkrequestSubcategory, id, prefix: prefix)
  def get_workrequest_subcategory(id, prefix), do: Repo.get(WorkrequestSubcategory, id, prefix: prefix)
  @doc """
  Creates a workrequest_subcategory.

  ## Examples

      iex> create_workrequest_subcategory(%{field: value})
      {:ok, %WorkrequestSubcategory{}}

      iex> create_workrequest_subcategory(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_workrequest_subcategory(attrs \\ %{}, prefix) do
    result = %WorkrequestSubcategory{}
              |> WorkrequestSubcategory.changeset(attrs)
              |> Repo.insert(prefix: prefix)
    case result do
      {:ok, workrequest_subcategory} -> {:ok, workrequest_subcategory }
      _ -> result
    end
  end

  @doc """
  Updates a workrequest_subcategory.

  ## Examples

      iex> update_workrequest_subcategory(workrequest_subcategory, %{field: new_value})
      {:ok, %WorkrequestSubcategory{}}

      iex> update_workrequest_subcategory(workrequest_subcategory, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_workrequest_subcategory(%WorkrequestSubcategory{} = workrequest_subcategory, attrs, prefix) do
    result = workrequest_subcategory
              |> WorkrequestSubcategory.changeset(attrs)
              |> Repo.update(prefix: prefix)
    case result do
      {:ok, workrequest_subcategory} -> {:ok, workrequest_subcategory |> Repo.preload(:workrequest_category, force: true)}
      _ -> result
    end
  end

  @doc """
  Deletes a workrequest_subcategory.

  ## Examples

      iex> delete_workrequest_subcategory(workrequest_subcategory)
      {:ok, %WorkrequestSubcategory{}}

      iex> delete_workrequest_subcategory(workrequest_subcategory)
      {:error, %Ecto.Changeset{}}

  """
  def delete_workrequest_subcategory(%WorkrequestSubcategory{} = workrequest_subcategory, prefix) do
    Repo.delete(workrequest_subcategory, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking workrequest_subcategory changes.

  ## Examples

      iex> change_workrequest_subcategory(workrequest_subcategory)
      %Ecto.Changeset{data: %WorkrequestSubcategory{}}

  """
  def change_workrequest_subcategory(%WorkrequestSubcategory{} = workrequest_subcategory, attrs \\ %{}) do
    WorkrequestSubcategory.changeset(workrequest_subcategory, attrs)
  end
end
