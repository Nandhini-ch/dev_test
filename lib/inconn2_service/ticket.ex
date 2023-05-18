defmodule Inconn2Service.Ticket do
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo
  import Ecto.Changeset
  import Inconn2Service.Util.DeleteManager
  # import Inconn2Service.Util.IndexQueries
  import Inconn2Service.Util.HelpersFunctions
  import Inconn2Service.Prompt
  import Inconn2Service.Staff

  alias Inconn2Service.Email
  alias Inconn2Service.Ticket.{WorkrequestCategory, WorkrequestStatusTrack}
  alias Inconn2Service.Staff
  alias Inconn2Service.Staff.User
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.AssetConfig.Site
  alias Inconn2Service.Common
  alias Inconn2Service.Prompt

  alias Inconn2Service.Ticket.CategoryHelpdesk
  alias Inconn2Service.Ticket.WorkRequest

  def list_workrequest_categories(prefix) do
    Repo.all(WorkrequestCategory, prefix: prefix) |> Repo.preload(:workrequest_subcategories)
    |> Repo.sort_by_id()
  end

  def list_workrequest_categories(_query_params, prefix) do
    WorkrequestCategory
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn wc -> preload_workrequest_subcategories(wc, prefix) end)
    |> Repo.sort_by_id()
  end

  def list_workrequest_categories_with_helpdesk_user(prefix) do
    WorkrequestCategory
    |> Repo.all(prefix: prefix)
    |> get_helpdesk_user_for_categories(prefix)
    |> Repo.sort_by_id()
  end

  def get_helpdesk_user_for_categories(categories, prefix) do
    Enum.map(categories, fn c ->
      helpdesk_users = Inconn2Service.Ticket.CategoryHelpdesk |> where([workrequest_category_id: ^c.id]) |> Repo.all(prefix: prefix)
      users = Enum.map(helpdesk_users, fn h -> Inconn2Service.Staff.get_user!(h.user_id, prefix) end)
      Map.put_new(c, :helpdesk_users, users)
    end)
  end

  def get_workrequest_category!(id, prefix), do: Repo.get!(WorkrequestCategory, id, prefix: prefix) |> Repo.preload(:workrequest_subcategories)

  def create_workrequest_category(attrs \\ %{}, prefix) do
    %WorkrequestCategory{}
    |> WorkrequestCategory.changeset(attrs)
    |> Repo.insert(prefix: prefix)
    |> preload_workrequest_subcategories(prefix)

  end

  def update_workrequest_category(%WorkrequestCategory{} = workrequest_category, attrs, prefix) do
    workrequest_category
    |> WorkrequestCategory.changeset(attrs)
    |> Repo.update(prefix: prefix)
    |> preload_workrequest_subcategories(prefix)

  end

  def delete_workrequest_category(%WorkrequestCategory{} = workrequest_category, prefix) do
    cond do
      has_workrequest_subcategory?(workrequest_category, prefix) ->
         {:could_not_delete,
           "Cannot be deleted as there are Workrequest Subcategory associated with it"
         }
       true ->
          update_workrequest_category(workrequest_category, %{"active" => false}, prefix)
            {:deleted,
               "The Workrequest Category was disabled"
             }
    end
  end

  def change_workrequest_category(%WorkrequestCategory{} = workrequest_category, attrs \\ %{}) do
    WorkrequestCategory.changeset(workrequest_category, attrs)
  end

  def list_work_requests(prefix) do
    Repo.all(WorkRequest, prefix: prefix)
    |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])
    |> Enum.map(fn wr -> preload_to_approve_users(wr, prefix) end)
    |> Enum.map(fn wr -> preload_asset(wr, prefix) end)
    |> Enum.filter(fn wr -> wr.status not in ["CS", "CL"] end)
    |> Repo.sort_by_id()
  end

  def preload_to_approve_users(work_request, prefix) do
    case work_request.approvals_required do
      nil ->
        Map.put_new(work_request, :approvals_required_user, [])

      ids ->
        if length(ids) != 0 do
          users =
            Enum.map(ids, fn id ->
              Inconn2Service.Staff.get_user!(id, prefix)
            end)
            Map.put_new(work_request, :approvals_required_user, users)
          else
            Map.put_new(work_request, :approvals_required_user, [])
        end
      end
  end

  def list_work_requests_for_actions(user, prefix) do
    %{
      raised_by_me: list_work_requests_for_raised_user(user, prefix),
      to_be_closed: list_work_requests_acknowledgement(user, prefix),
      helpdesk: list_work_requests_for_helpdesk_user(user, prefix)
    }
  end

  def list_work_requests_for_raised_user(user, prefix) do
    from(w in WorkRequest, where: w.requested_user_id == ^user.id and w.status not in ["CS", "CL"])
    |> Repo.all(prefix: prefix) |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])
    |> Enum.map(fn wr ->  preload_to_approve_users(wr, prefix) end)
    |> Enum.map(fn wr -> preload_asset(wr, prefix) end)
    |> Repo.sort_by_id()
  end

  def list_work_requests_for_team(user, prefix) when not is_nil(user.employee_id) do
    teams = Staff.get_team_ids_for_user(user, prefix)
    team_user_ids = Staff.get_team_users(teams, prefix) |> Enum.map(fn u -> u.id end)
    |> IO.inspect()
    from(w in WorkRequest, where: w.assigned_user_id in ^team_user_ids and w.status not in ["CS", "CL"])
    |> Repo.all(prefix: prefix) |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])
    |> Enum.map(fn wr ->  preload_to_approve_users(wr, prefix) end)
    |> Enum.map(fn wr -> preload_asset(wr, prefix) end)
    |> Repo.sort_by_id()
  end

  def list_work_requests_for_team(_user, _prefix), do: []

  def list_work_requests_for_assigned_user(user, prefix) do
    from(w in WorkRequest, where: w.assigned_user_id == ^user.id and w.status not in ["CS", "CL"])
    WorkRequest |> where([assigned_user_id: ^user.id])
    |> Repo.all(prefix: prefix)
    |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])
    |> Enum.map(fn wr ->  preload_to_approve_users(wr, prefix) end)
    |> Enum.map(fn wr -> preload_asset(wr, prefix) end)
    |> Repo.sort_by_id()
  end

  def list_work_requests_acknowledgement(user, prefix) do
    WorkRequest
    |> where([requested_user_id: ^user.id, status: "CP"])
    |> Repo.all(prefix: prefix) |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])
    |> Enum.map(fn wr ->  preload_to_approve_users(wr, prefix) end)
    |> Enum.map(fn wr -> preload_asset(wr, prefix) end)
    |> Repo.sort_by_id()
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
        |> Enum.filter(fn wr -> wr.status not in ["CS", "CL"] end)
        |> Enum.map(fn wr ->  preload_to_approve_users(wr, prefix) end)
        |> Enum.map(fn wr -> preload_asset(wr, prefix) end)


      "E" ->
        equipment = Inconn2Service.AssetConfig.get_equipment_by_qr_code(uuid, prefix)
        WorkRequest
        |> where([asset_id: ^equipment.id, assigned_user_id: ^user.id])
        |> Repo.all(prefix: prefix)
        |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])
        |> Enum.filter(fn wr -> wr.status not in ["CS", "CL"] end)
        |> Enum.map(fn wr ->  preload_to_approve_users(wr, prefix) end)
        |> Enum.map(fn wr -> preload_asset(wr, prefix) end)
    end
  end

  def list_work_requests_for_approval(current_user, prefix) do
    query = from w in WorkRequest, where: ^current_user.id in w.approvals_required and w.status not in ["AP", "RJ", "CL", "CP", "ROP", "CS"]
    Repo.all(query, prefix: prefix) |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])
    |> Enum.filter(fn wr -> wr.status not in ["CS", "CL"] end)
    |> Enum.map(fn wr ->  preload_to_approve_users(wr, prefix) end)
    |> Enum.map(fn wr -> preload_asset(wr, prefix) end)
    |> Enum.filter(fn wr -> !exclude_work_request_approved(wr, current_user, prefix) end)
    |> Repo.sort_by_id()
  end

  def list_pending_work_request_for_approval(user, prefix) do
    teams = Staff.get_team_ids_for_user(user, prefix)
    team_user_ids = Staff.get_team_users(teams, prefix) |> Enum.map(fn u -> u.id end)
    query = from w in WorkRequest, where: w.status not in ["AP", "RJ", "CL", "CP", "ROP", "CS"]
    Repo.all(query, prefix: prefix) |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])
    |> Enum.filter(fn wr -> wr.status not in ["CS", "CL"] end)
    |> filter_for_workrequest_approval_in_team(team_user_ids)
    |> Enum.map(fn wr ->  preload_to_approve_users(wr, prefix) end)
    |> Enum.map(fn wr -> preload_asset(wr, prefix) end)
    |> Enum.filter(fn wr -> !exclude_work_request_approved(wr, user, prefix) end)
    |> Repo.sort_by_id()
  end

  def filter_for_workrequest_approval_in_team(work_requests, team_user_ids) do
    Enum.reject(work_requests, fn wr -> is_nil(wr.approvals_required) end)
    |> Enum.filter(fn wr ->
        boolean_list = Enum.map(team_user_ids, fn user_id -> user_id in wr.approvals_required end)
        true in boolean_list
      end)
  end

  defp exclude_work_request_approved(work_request, current_user, prefix) do
    from(a in Inconn2Service.Ticket.Approval, where: a.work_request_id == ^work_request.id and a.user_id == ^current_user.id)
    |> Repo.exists?(prefix: prefix)
  end

  def list_work_requests_sent_for_approval(current_user, prefix) do
    query = from w in WorkRequest, where: w.assigned_user_id == ^current_user.id and w.is_approvals_required and w.status in ["RS", "AS"]
    Repo.all(query, prefix: prefix) |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])
    |> Enum.filter(fn wr -> wr.status not in ["CS", "CL"] end)
    |> Enum.map(fn wr ->  preload_to_approve_users(wr, prefix) end)
    |> Enum.map(fn wr -> preload_asset(wr, prefix) end)
    |> Repo.sort_by_id()
  end

  def list_work_requests_for_helpdesk_user(current_user, prefix) do
    helpdesk = get_category_helpdesk_by_user(current_user.id, prefix)
    if helpdesk != [] do
      workrequest_category_ids = Enum.map(helpdesk, fn x -> x.workrequest_category_id end)
      site_ids = Enum.map(helpdesk, fn x -> x.site_id end)
      from(wr in WorkRequest, where: wr.workrequest_category_id in ^workrequest_category_ids and wr.site_id in ^site_ids and wr.status != "CS")
      |> Repo.all(prefix: prefix)
      |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])
      |> Enum.filter(fn wr -> wr.status not in ["CS", "CL"] end)
      |> Enum.map(fn wr ->  preload_to_approve_users(wr, prefix) end)
      |> Enum.map(fn wr -> preload_asset(wr, prefix) end)
      |> Repo.sort_by_id()
    else
      []
    end
  end

  defp preload_asset(work_request, prefix) when work_request.asset_id != nil do
    case work_request.asset_type do
      "L" ->
        asset = AssetConfig.get_location(work_request.asset_id, prefix)
        Map.put(work_request, :asset, asset)
      "E" ->
        asset = AssetConfig.get_equipment(work_request.asset_id, prefix)
        Map.put(work_request, :asset, asset)
      _ ->
        Map.put(work_request, :asset, nil)
    end
  end

  defp preload_asset(work_request, _prefix) do
    Map.put(work_request, :asset, nil)
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
                                          |> preload_to_approve_users(prefix)
                                          |> preload_asset(prefix)

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
        Elixir.Task.start(fn -> push_alert_notification_for_new_ticket(work_request, prefix, work_request.site_id) end)
        {:ok, work_request |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])|> preload_to_approve_users(prefix) |> preload_asset(prefix)}

      _ ->
        created_work_request

    end
  end

  def auto_fill_wr_category(cs, prefix) do
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

  def validate_asset_id(cs, prefix) do
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

  def create_status_track(work_request, prefix) do
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
    result = work_request
              |> WorkRequest.changeset(payload)
              |> auto_fill_wr_category(prefix)
              |> validate_asset_id(prefix)
              |> attachment_format(attrs)
              |> validate_assigned_user_id(prefix)
              |> is_approvals_required(user, prefix)
              |> validate_approvals_required_ids(prefix)
              |> calculate_tat(work_request, prefix)
              |> update_workorder_generated_status()
              |> Repo.update(prefix: prefix)


    case result do
      {:ok, updated_work_request} ->
        {:ok, status_track} = update_status_track(updated_work_request, prefix)
        Elixir.Task.start(fn -> push_alert_notification_for_ticket(updated_work_request.asset_id, updated_work_request.asset_type, updated_work_request.workrequest_category_id, work_request, updated_work_request, prefix, updated_work_request.site_id) end)
        update_status_track(updated_work_request, prefix)
        Elixir.Task.start(fn -> send_completed_email(work_request, updated_work_request, status_track, prefix) end)
        {:ok, updated_work_request |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee], force: true) |> preload_to_approve_users(prefix) |> preload_asset(prefix)}

      _ ->
        result
    end
  end

  def update_workorder_generated_status(cs) do
    case get_field(cs, :status) do
      "ROP" -> change(cs, %{is_workorder_generated: false})
      _ -> cs
    end
  end

  defp send_completed_email(work_request, updated_work_request, status_track, prefix) do
    cond do
      work_request.status != "CP" and updated_work_request.status == "CP" ->
            date_time = NaiveDateTime.new!(status_track.status_update_date, status_track.status_update_time) |> NaiveDateTime.to_iso8601()
            Email.send_ticket_complete_email(updated_work_request.id, updated_work_request.external_email, updated_work_request.external_name, updated_work_request.remarks, date_time, prefix)
          updated_work_request
      true ->
          updated_work_request
    end
  end

  def update_user_for_workorder(existing_workrequest, updated_workrequest, prefix, user) do
    cond do
      !is_nil(updated_workrequest.assigned_user_id) && updated_workrequest.assigned_user_id != existing_workrequest.assigned_user_id ->
          work_order =
            Inconn2Service.Workorder.WorkOrder
            |> where([work_request_id: ^updated_workrequest.id])
            |> Repo.all(prefix: prefix)
            |> Enum.filter(fn wo -> wo.status in ["cr, as"]  end)
            |> Enum.sort_by(&(&1.inserted_at))
            |> List.last()

          case work_order do
            nil ->
              {:ok, updated_workrequest}

            _ ->
              Inconn2Service.Workorder.update_work_order(work_order, %{"user_id" => updated_workrequest.assigned_user_id}, prefix, user)
              {:ok, updated_workrequest}
          end


      true ->
        {:ok, updated_workrequest}
    end
  end

  def update_work_requests(work_request_changes, prefix, user) do
    Enum.map(work_request_changes["ids"], fn id ->
      work_request = get_work_request!(id, prefix)
      {:ok, work_request} = update_work_request(work_request, Map.drop(work_request_changes, ["ids"]), prefix, user)
      work_request |> preload_to_approve_users(prefix) |> preload_asset(prefix)
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
      cond do
        work_request.status == "RS" and status != "RS" ->
          tat = NaiveDateTime.diff(site_dt, raised_dt) / 60 |> trunc()
          change(cs, %{response_tat: tat})

        work_request.status != "CP" and status == "CP" ->
          tat = NaiveDateTime.diff(site_dt, raised_dt) / 60 |> trunc()
          change(cs, %{resolution_tat: tat})
        true ->
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

  def update_status_track(work_request, prefix) do
        {date, time} = get_date_time_in_required_time_zone(work_request, prefix)
        workrequest_status_track = %{
          "work_request_id" => work_request.id,
          "status_update_date" => date,
          "status_update_time" => time,
          "status" => work_request.status
        }
        create_workrequest_status_track(workrequest_status_track, prefix)
  end

  defp validate_approvals_required_ids(cs, prefix) do
    is_approvals_required = get_change(cs, :is_approvals_required, nil)
    if is_approvals_required do
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


  def list_category_helpdesks(_query_params, prefix) do
    CategoryHelpdesk
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
    |> Repo.preload([:site, workrequest_category: :workrequest_subcategories, user: :employee])
    |> Repo.sort_by_id()
  end

  def get_category_helpdesk!(id, prefix), do: Repo.get!(CategoryHelpdesk, id, prefix: prefix) |> Repo.preload([:site, workrequest_category: :workrequest_subcategories, user: :employee])

  def get_category_helpdesk_by_user(user_id, prefix) do
    CategoryHelpdesk
    |> where(user_id: ^user_id)
    |> Repo.all(prefix: prefix)
    |> Repo.sort_by_id()
  end

  def get_category_helpdesk_by_workrequest_category(workrequest_catgoery_id, site_id, prefix) do
    from(ch in CategoryHelpdesk, where: ch.workrequest_category_id == ^workrequest_catgoery_id and ch.site_id == ^site_id)
    |> Repo.all(prefix: prefix)
    |> Repo.sort_by_id()
  end

  def group_helpdesk_users_by_workrequest_category_id(workrequest_category_id, site_id, prefix) do
    from(ch in CategoryHelpdesk, where: ch.workrequest_category_id == ^workrequest_category_id and ch.site_id == ^site_id)
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn a -> a.user_id end)
  end

  def create_category_helpdesk(attrs \\ %{}, prefix) do
    result = %CategoryHelpdesk{}
              |> CategoryHelpdesk.changeset(attrs)
              |> validate_user_id(prefix)
              # |> validate_category_helpdesk_constraint(prefix)
              |> Repo.insert(prefix: prefix)
    case result do
      {:ok, category_helpdesk} -> {:ok, category_helpdesk |> Repo.preload([:site, workrequest_category: :workrequest_subcategories, user: :employee])}
       _ -> result
    end
  end

  # def get_category_helpdesk_by_user(nil, nil, nil, _prefix), do: []

  # def get_category_helpdesk_by_user(user_id, site_id, workrequest_category_id, prefix) do
  #   from(c in CategoryHelpdesk, where: c.user_id == ^user_id and c.site_id == ^site_id and c.workrequest_category_id == ^workrequest_category_id)
  #   |> Repo.all(prefix: prefix)
  # end

  # def validate_category_helpdesk_constraint(cs, prefix) do
  #   user_id = get_change(cs, :user_id, nil)
  #   site_id = get_change(cs, :site_id, nil)
  #   workrequest_category_id = get_change(cs, :workrequest_category_id, nil)
  #   if 0 >= length(get_category_helpdesk_by_user(, prefix)) do
  #     cs
  #   else
  #     add_error(cs, :user_id, "This Category Helpdesk Is Already Assigned")
  #   end
  # end

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

  def update_category_helpdesk(%CategoryHelpdesk{} = category_helpdesk, attrs, prefix) do
    result = category_helpdesk
              |> CategoryHelpdesk.changeset(attrs)
              |> validate_user_id(prefix)
              # |> validate_category_helpdesk_constraint(prefix)
              |> Repo.update(prefix: prefix)
    case result do
      {:ok, category_helpdesk} -> {:ok, category_helpdesk |> Repo.preload([:site, workrequest_category: :workrequest_subcategories, user: :employee], force: true)}
      _ -> result
    end
  end


  def delete_category_helpdesk(%CategoryHelpdesk{} = category_helpdesk, prefix) do
        update_category_helpdesk(category_helpdesk, %{"active" => false}, prefix)
          {:deleted,
             "The Category Helpdesk was disabled"
           }
  end

  def change_category_helpdesk(%CategoryHelpdesk{} = category_helpdesk, attrs \\ %{}) do
    CategoryHelpdesk.changeset(category_helpdesk, attrs)
  end

  alias Inconn2Service.Ticket.WorkrequestStatusTrack

  def list_workrequest_status_track(prefix) do
    Repo.all(WorkrequestStatusTrack, prefix: prefix)
    |> Repo.sort_by_id()
  end

  def list_workrequest_status_track_for_work_request(work_request_id, prefix) do
    WorkrequestStatusTrack
    |> where(work_request_id: ^work_request_id)
    |> Repo.all(prefix: prefix)
    |> Repo.sort_by_id()
  end

  def get_workrequest_status_track!(id, prefix), do: Repo.get!(WorkrequestStatusTrack, id, prefix: prefix)

  def create_workrequest_status_track(attrs \\ %{}, prefix) do
    %WorkrequestStatusTrack{}
    |> WorkrequestStatusTrack.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_workrequest_status_track(%WorkrequestStatusTrack{} = workrequest_status_track, attrs, prefix) do
    workrequest_status_track
    |> WorkrequestStatusTrack.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end


  def delete_workrequest_status_track(%WorkrequestStatusTrack{} = workrequest_status_track, prefix) do
    Repo.delete(workrequest_status_track, prefix: prefix)
  end

  def change_workrequest_status_track(%WorkrequestStatusTrack{} = workrequest_status_track, attrs \\ %{}) do
    WorkrequestStatusTrack.changeset(workrequest_status_track, attrs)
  end

  alias Inconn2Service.Ticket.Approval

  def list_approvals(prefix) do
    Repo.all(Approval, prefix: prefix) |> Repo.preload([:work_request, :user])
  end

  def list_approvals_for_work_order(work_request_id, prefix) do
    Approval
    |> where(work_request_id: ^work_request_id)
    |> Repo.all(prefix: prefix)
    |> Repo.preload([:work_request, :user])
    |> Repo.sort_by_id()
  end

  def get_approval!(id, prefix), do: Repo.get!(Approval, id, prefix: prefix) |> Repo.preload([:work_request, :user])

  def create_approval(attrs \\ %{}, prefix, user) do
    # IO.inspect(attrs)
    result = %Approval{}
              |> Approval.changeset(attrs)
              |> set_approver_user_id(user)
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
    case get_change(cs, :user_id, nil) do
      nil -> change(cs, %{user_id: user.id})
      _ -> cs
    end
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

  def update_approval(%Approval{} = approval, attrs, prefix, user) do
    result = approval
              |> Approval.changeset(attrs)
              |> set_approver_user_id(user)
              |> Repo.update(prefix: prefix)
    update_status_for_work_request(result, prefix)
  end

  def delete_approval(%Approval{} = approval, prefix) do
    Repo.delete(approval, prefix: prefix)
  end


  def change_approval(%Approval{} = approval, attrs \\ %{}) do
    Approval.changeset(approval, attrs)
  end

  alias Inconn2Service.Ticket.WorkrequestSubcategory

  def list_workrequest_subcategories_for_category(workrequest_category_id, prefix) do
    WorkrequestSubcategory
    |> where(workrequest_category_id: ^workrequest_category_id)
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)

  end

  def get_workrequest_subcategory!(id, prefix), do: Repo.get!(WorkrequestSubcategory, id, prefix: prefix)
  def get_workrequest_subcategory(id, prefix), do: Repo.get(WorkrequestSubcategory, id, prefix: prefix)

  def create_workrequest_subcategory(attrs \\ %{}, prefix) do
    result = %WorkrequestSubcategory{}
              |> WorkrequestSubcategory.changeset(attrs)
              |> Repo.insert(prefix: prefix)
    case result do
      {:ok, workrequest_subcategory} ->
        # push_alert_notification_for_ticket_category(workrequest_subcategory, site_id, user, prefix)
        {:ok, workrequest_subcategory }
      _ -> result
    end
  end

  def update_workrequest_subcategory(%WorkrequestSubcategory{} = workrequest_subcategory, attrs, prefix) do
    result = workrequest_subcategory
              |> WorkrequestSubcategory.changeset(attrs)
              |> Repo.update(prefix: prefix)
    case result do
      {:ok, workrequest_subcategory} -> {:ok, workrequest_subcategory |> Repo.preload(:workrequest_category, force: true)}
      _ -> result
    end
  end

  def delete_workrequest_subcategory(%WorkrequestSubcategory{} = workrequest_subcategory, prefix) do
    cond do
      has_work_request?(workrequest_subcategory, prefix) ->
         {:could_not_delete,
           "Cannot be deleted as there are Ticket associated with it"
         }
       true ->
        update_workrequest_subcategory(workrequest_subcategory, %{"active" => false}, prefix)
          {:deleted,
             "The Workrequest Subcategory was disabled"
           }
    end
  end

  def change_workrequest_subcategory(%WorkrequestSubcategory{} = workrequest_subcategory, attrs \\ %{}) do
    WorkrequestSubcategory.changeset(workrequest_subcategory, attrs)
  end

  def push_alert_notification_for_ticket_category(_category, site_id, user, prefix) do
    user = get_display_name_for_user_id(user.id, prefix)
    generate_alert_notification("TNCSC", site_id, [user], [], [], [], prefix)
  end

  def push_alert_notification_for_new_ticket(work_request, prefix, site_id) do
    helpdesk_users = group_helpdesk_users_by_workrequest_category_id(work_request.workrequest_category_id, site_id, prefix)
    workrequest_category = get_workrequest_category!(work_request.workrequest_category_id, prefix)
    date_time = get_site_date_time_now(site_id, prefix)
    work_request_type =
      case work_request.request_type do
        "CO" -> "Complaint"
        "RE" -> "Request"
      end

    requested_user = get_display_name_for_user_id(work_request.requested_user_id, prefix)
    user_maps = Staff.form_user_maps_by_user_ids(helpdesk_users, prefix)

    generate_alert_notification("NTGEN", site_id, [work_request_type, work_request.id, requested_user, date_time], [workrequest_category.name, work_request.id, requested_user, date_time], user_maps, [], prefix)

  end

  # def push_alert_notification_for_ticket(nil, updated_work_request, prefix, _user) do
  #   work_request_type =
  #     case updated_work_request.request_type do
  #       "CO" -> "Complaint"
  #       "RE" -> "Request"
  #     end

  #   requested_user = Staff.get_user!(updated_work_request.requested_user_id, prefix)

  #   user =
  #     case requested_user.employee do
  #       nil -> requested_user.username
  #       _ -> requested_user.employee.first_name
  #     end

  #   description = ~s(#{work_request_type} #{updated_work_request.id} created by #{user} at #{updated_work_request.raised_date_time})
  #   create_ticket_alert_notification("WRNW", description, updated_work_request, "new ticket raised", prefix)

  # end

  def push_alert_notification_for_ticket(asset_id, asset_type, workrequest_category_id, existing_work_request, updated_work_request, prefix, site_id) do
    helpdesk_users = group_helpdesk_users_by_workrequest_category_id(workrequest_category_id, site_id, prefix)
    asset = AssetConfig.get_asset_by_asset_id(asset_id, asset_type, prefix)
    date_time = get_site_date_time_now(site_id, prefix)
    assigned_user = get_display_name_for_user_id(updated_work_request.assigned_user_id, prefix)
    work_request_type =
      case updated_work_request.request_type do
        "CO" -> "Complaint"
        "RE" -> "Request"
      end

    status =
      case updated_work_request.status do
        "RS" -> "Raised"
        "AP" -> "Approved"
        "AS" -> "Assigned"
        "RJ" -> "Rejected"
        "CL" -> "Closed"
        "CS" -> "Cancelled"
        "ROP" -> "Reopened"
        "CP" -> "Completed"
      end

    # user =
    #   cond do
    #     is_nil(user) -> "external user"
    #     is_nil(user.employee) -> user.username
    #     true -> user.employee.first_name
    #   end

    cond do
      #new ticket assigned
      existing_work_request.assigned_user_id == nil && updated_work_request.assigned_user_id != nil ->
        user_maps = Staff.form_user_maps_by_user_ids([updated_work_request.assigned_user_id], prefix)
        generate_alert_notification("NTASS", site_id, [updated_work_request.id, status, assigned_user], [updated_work_request.id, status, assigned_user], user_maps, [], prefix)

      #ticket approval status change
      existing_work_request.status != updated_work_request.status and updated_work_request.status in ["AP", "RJ"] ->
        user_maps = Staff.form_user_maps_by_user_ids(helpdesk_users, prefix)
        generate_alert_notification("TAPSC", site_id, [updated_work_request.id, status, assigned_user], [updated_work_request.id, status, assigned_user], user_maps, [], prefix)

      #ticket completed
      existing_work_request.status != updated_work_request.status and updated_work_request.status == "CP" ->
        user_maps = Staff.form_user_maps_by_user_ids(helpdesk_users, prefix)
        generate_alert_notification("TCKCP", site_id, [updated_work_request.id, status, assigned_user], [updated_work_request.id, status, assigned_user], user_maps, [], prefix)

      #ticket cancelled
      existing_work_request.status != updated_work_request.status and updated_work_request.status == "CL" ->
        user_maps = Staff.form_user_maps_by_user_ids([updated_work_request.assigned_user_id], prefix)
        escalation_user_maps = Staff.form_user_maps_by_user_ids([asset.asset_manager_id], prefix)
        generate_alert_notification("TCKCN", site_id, [work_request_type, updated_work_request.id, assigned_user, date_time], [updated_work_request.workrequest_category_id.name, updated_work_request.id, assigned_user, date_time], user_maps, escalation_user_maps, prefix)

      #ticket reopened
      existing_work_request.status != updated_work_request.status and updated_work_request.status == "ROP" ->
        user_ids = [updated_work_request.assigned_user_id, asset.asset_manager_id] ++ helpdesk_users
        user_maps = form_user_maps_by_user_ids(user_ids, prefix)
        escalation_user_maps = Staff.form_user_maps_by_user_ids([asset.asset_manager_id], prefix)
        generate_alert_notification("TCKRO", site_id, [updated_work_request.id, assigned_user, date_time], [updated_work_request.id, assigned_user, date_time], user_maps,  escalation_user_maps, prefix)

      #ticket reassigned
      existing_work_request.assigned_user_id != nil && existing_work_request.assigned_user_id != updated_work_request.assigned_user_id ->
        escalation_user_maps = Staff.form_user_maps_by_user_ids([asset.asset_manager_id], prefix)
        generate_alert_notification("TCKRR", site_id, [updated_work_request.id, assigned_user], [updated_work_request.id, "Reassign", assigned_user], [], escalation_user_maps, prefix)

      true ->
        {:ok, updated_work_request}
    end
  end

  defp create_ticket_alert_notification(alert_code, description, updated_work_request, action_for, prefix) do
    alert = Common.get_alert_by_code(alert_code)
    alert_config = Prompt.get_alert_notification_config_by_alert_id_and_site_id(alert.id, updated_work_request.site_id, prefix)
    alert_identifier_date_time = NaiveDateTime.utc_now()
    attrs = %{
      "alert_notification_id" => alert.id,
      "type" => alert.type,
      "description" => description,
      "site_id" => alert_config.site_id,
      "alert_identifier_date_time" => alert_identifier_date_time
    }

    config_user_ids =
      case alert_config do
        nil -> []
        _ -> alert_config.addressed_to_user_ids
      end

    case action_for do
      "category/sub_category created" ->
        Enum.map(config_user_ids, fn id ->
          Prompt.create_user_alert_notification(Map.put_new(attrs, "user_id", id), prefix)
        end)
        create_escalation_entry(alert, alert_config, alert_identifier_date_time, prefix)

      "new ticket raised" ->
        helpdesk_users = get_category_helpdesk_by_workrequest_category(updated_work_request.workrequest_category_id, updated_work_request.site_id, prefix)
                         |> Enum.map(fn x -> x.user_id end)
        Enum.map(config_user_ids ++ helpdesk_users, fn id ->
          Prompt.create_user_alert_notification(Map.put_new(attrs, "user_id", id), prefix)
        end)
        create_escalation_entry(alert, alert_config, alert_identifier_date_time, prefix)

      "new ticket assigned" ->
        Enum.map(config_user_ids ++ [updated_work_request.assigned_user_id], fn id ->
          Prompt.create_user_alert_notification(Map.put_new(attrs, "user_id", id), prefix)
        end)
        create_escalation_entry(alert, alert_config, alert_identifier_date_time, prefix)

      "ticket approved/rejected" ->
        helpdesk_users = get_category_helpdesk_by_workrequest_category(updated_work_request.workrequest_category_id, updated_work_request.site_id, prefix)
                         |> Enum.map(fn x -> x.user_id end)
        Enum.map(config_user_ids ++ helpdesk_users, fn id ->
          Prompt.create_user_alert_notification(Map.put_new(attrs, "user_id", id), prefix)
        end)
        create_escalation_entry(alert, alert_config, alert_identifier_date_time, prefix)

      "ticket completed" ->
        assigned_user_id =
           case updated_work_request.assigned_user_id do
            nil  -> []
            _ -> [updated_work_request.assigned_user_id]
           end
        Enum.map(config_user_ids ++ assigned_user_id, fn id ->
          Prompt.create_user_alert_notification(Map.put_new(attrs, "user_id", id), prefix)
        end)
        create_escalation_entry(alert, alert_config, alert_identifier_date_time, prefix)

      "ticket reassigned" ->
        assigned_user_id =
          case updated_work_request.assigned_user_id do
           nil  -> []
           _ -> [updated_work_request.assigned_user_id]
          end
        Enum.map(config_user_ids ++ assigned_user_id, fn id ->
          Prompt.create_user_alert_notification(Map.put_new(attrs, "user_id", id), prefix)
        end)
        create_escalation_entry(alert, alert_config, alert_identifier_date_time, prefix)

      "ticket cancelled" ->
        assigned_user_id =
          case updated_work_request.assigned_user_id do
           nil  -> []
           _ -> [updated_work_request.assigned_user_id]
          end
        Enum.map(config_user_ids ++ assigned_user_id, fn id ->
          Prompt.create_user_alert_notification(Map.put_new(attrs, "user_id", id), prefix)
        end)
        create_escalation_entry(alert, alert_config, alert_identifier_date_time, prefix)

      "ticket reopened" ->
        assigned_user_id =
          case updated_work_request.assigned_user_id do
           nil  -> []
           _ -> [updated_work_request.assigned_user_id]
          end
        helpdesk_users = get_category_helpdesk_by_workrequest_category(updated_work_request.workrequest_category_id, updated_work_request.site_id, prefix)
                         |> Enum.map(fn x -> x.user_id end)
        Enum.map(config_user_ids ++ assigned_user_id ++ helpdesk_users, fn id ->
          Prompt.create_user_alert_notification(Map.put_new(attrs, "user_id", id), prefix)
        end)
        create_escalation_entry(alert, alert_config, alert_identifier_date_time, prefix)
    end

  end

  defp create_escalation_entry(_alert, nil, _alert_identifier_date_time, _prefix), do: nil

  defp create_escalation_entry(alert, alert_config, alert_identifier_date_time, prefix) do
    if alert.type == "al" and alert_config.is_escalation_required do
      Common.create_alert_notification_scheduler(%{
        "alert_code" => alert.code,
        "site_id" => alert_config.site_id,
        "alert_identifier_date_time" => alert_identifier_date_time,
        "escalation_at_date_time" => NaiveDateTime.add(alert_identifier_date_time, alert_config.escalation_time_in_minutes * 60),
        # "escalated_to_user_ids" => alert_config.escalated_to_user_ids,
        "prefix" => prefix
      })
    end
  end


  defp preload_workrequest_subcategories({:error, changeset}, _prefix), do: {:error, changeset}
  defp preload_workrequest_subcategories({:ok, category}, prefix), do: {:ok, preload_workrequest_subcategories(category, prefix)}
  defp preload_workrequest_subcategories(category, prefix), do: Map.put(category, :workrequest_subcategories, list_workrequest_subcategories_for_category(category.id, prefix))

  alias Inconn2Service.Ticket.WorkrequestFeedback

  def list_workrequest_feedbacks(prefix) do
    Repo.all(WorkrequestFeedback, prefix: prefix)
  end


  def get_workrequest_feedback!(id, prefix), do: Repo.get!(WorkrequestFeedback, id, prefix: prefix)

  def create_workrequest_feedback(attrs \\ %{}, prefix) do
    %WorkrequestFeedback{}
    |> WorkrequestFeedback.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end


  def update_workrequest_feedback(%WorkrequestFeedback{} = workrequest_feedback, attrs, prefix) do
    workrequest_feedback
    |> WorkrequestFeedback.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_workrequest_feedback(%WorkrequestFeedback{} = workrequest_feedback, prefix) do
    Repo.delete(workrequest_feedback, prefix: prefix)
  end


  def change_workrequest_feedback(%WorkrequestFeedback{} = workrequest_feedback, attrs \\ %{}) do
    WorkrequestFeedback.changeset(workrequest_feedback, attrs)
  end
end
