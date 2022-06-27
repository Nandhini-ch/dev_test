defmodule Inconn2Service.ExternalTicket do

  #QR code

  def generate_equipment_ticket_qr_as_pdf(equipment, prefix), do: render_string(equipment, split_prefix(prefix), "equipments") |> convert_string_to_pdf(equipment)
  def generate_location_ticket_qr_as_pdf(location, prefix), do: render_string(location, split_prefix(prefix), "locations") |> convert_string_to_pdf(location)

  def generate_location_ticket_qr(asset, prefix), do: EQRCode.encode(generate_asset_base_url(asset, "L", prefix)) |> EQRCode.png
  def generate_equipment_ticket_qr(asset, prefix), do: EQRCode.encode(generate_asset_base_url(asset, "E", prefix)) |> EQRCode.png

  defp put_location_id(asset, "E"), do: "location_id=#{asset.location_id}"
  defp put_location_id(asset, "L"), do: "location_id=#{asset.id}"

  defp generate_asset_base_url(asset, asset_type, prefix) do
    "https://#{split_prefix(prefix)}.inconn.io/externalticket?asset_id=#{asset.id}&asset_type=#{asset_type}&site_id=#{asset.site_id}&#{put_location_id(asset, asset_type)}"
  end

  defp split_prefix(prefix) do
    "inc_" <> sub_domain = prefix
    sub_domain
  end

  defp style(style_map) do
    style_map
    |> Enum.map(fn {key, value} ->
      "#{key}: #{value}"
    end)
    |> Enum.join(";")
  end

  defp convert_string_to_pdf(string, asset) do
    {:ok, filename} = PdfGenerator.generate(string, page_size: "A4")
    {:ok, pdf_content} = File.read(filename)
    {asset.name, pdf_content}
  end

  defp render_string(asset, sub_domain, asset_type) do
    Sneeze.render(
      [
        :center,
        [
          :img,
          %{
            src: "http://#{sub_domain}.localhost:4000/api/#{asset_type}/#{asset.id}/ticket_qr_code_png",
            style: style(%{
              "margin-top" => "150px",
              "height" => "800px",
              "width" => "800px"
            })
          }
        ],
        [:h6, %{style: style(%{"width" => "600px", "font-size" => "20px"})}, "To raise a complaint, scan the qr"],
        [:h3, %{style: style(%{"width" => "600px", "font-size" => "50px"})}, "#{asset.name}"],
        [
          :span,
          %{"style" => style(%{"float" => "right", "margin-top" => "100px"})},
          "Powered By InConn"
        ]
      ]
    )
  end

  #Ticket Database Functions

  alias Inconn2Service.Repo
  alias Inconn2Service.Ticket
  alias Inconn2Service.Ticket.WorkRequest
  alias Inconn2Service.Email

  def get_work_request!(id, prefix), do: Repo.get!(WorkRequest, id, prefix: prefix) |> Repo.preload([:workrequest_category, :workrequest_subcategory])

  def create_external_work_request(attrs \\ %{}, prefix) do
    attrs =
      attrs
      |> Map.put("request_type", "CO")
      |> Map.put("is_external_ticket", true)

    created_work_request = %WorkRequest{}
    |> WorkRequest.external_ticket_changeset(attrs)
    |> Ticket.auto_fill_wr_category(prefix)
    |> Ticket.validate_asset_id(prefix)
    |> Repo.insert(prefix: prefix)

    case created_work_request do
      {:ok, work_request} ->
        Email.send_ticket_reg_email(work_request.id, work_request.external_email, work_request.external_name)
        Ticket.create_status_track(work_request, prefix)
        Ticket.push_alert_notification_for_ticket(nil, work_request, prefix, nil)
        {:ok, work_request |> Repo.preload([:workrequest_category, :workrequest_subcategory])}

      _ ->
        created_work_request

    end
  end

  def update_external_work_request(%WorkRequest{} = work_request, attrs, prefix) do
    result = work_request
              |> WorkRequest.external_ticket_changeset(attrs)
              |> Ticket.auto_fill_wr_category(prefix)
              |> Ticket.validate_asset_id(prefix)
              |> Repo.update(prefix: prefix)

    case result do
      {:ok, updated_work_request} ->
        Ticket.update_status_track(updated_work_request, prefix)
        Ticket.push_alert_notification_for_ticket(work_request, updated_work_request, prefix, nil)
        {:ok, updated_work_request |> Repo.preload([:workrequest_category, :workrequest_subcategory], force: true)}

      _ ->
        result

    end
  end

end
