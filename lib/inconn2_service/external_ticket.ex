defmodule Inconn2Service.ExternalTicket do

  @base_url "localhost:4000/externalticket"
  #QR code

  def generate_equipment_ticket_qr_as_pdf(equipment, prefix), do: render_string(equipment, split_prefix(prefix), "equipments") |> convert_string_to_pdf(equipment)
  def generate_location_ticket_qr_as_pdf(location, prefix), do: render_string(location, split_prefix(prefix), "locations") |> convert_string_to_pdf(location)

  def generate_location_ticket_qr(asset, prefix), do: EQRCode.encode(generate_asset_base_url(asset, "L", prefix)) |> EQRCode.png
  def generate_equipment_ticket_qr(asset, prefix), do: EQRCode.encode(generate_asset_base_url(asset, "E", prefix)) |> EQRCode.png

  defp put_location_id(asset, "E"), do: "location_id=#{asset.location_id}"
  defp put_location_id(asset, "L"), do: "location_id=#{asset.id}"

  defp generate_asset_base_url(asset, asset_type, prefix) do
    "#{split_prefix(prefix)}.#{@base_url}?asset_id=#{asset.id}&asset_type=#{asset_type}&site_id=#{asset.site_id}&sub_domain=#{split_prefix(prefix)}&#{put_location_id(asset, asset_type)}"
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



end
