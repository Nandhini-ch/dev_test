defmodule Inconn2ServiceWeb.Apk_versionView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.Apk_versionView

  def render("index.json", %{apk_versions: apk_versions}) do
    %{data: render_many(apk_versions, Apk_versionView, "apk_version.json")}
  end

  def render("show.json", %{apk_version: apk_version}) do
    %{data: render_one(apk_version, Apk_versionView, "apk_version.json")}
  end

  def render("apk_version.json", %{apk_version: apk_version}) do
    %{id: apk_version.id,
      version_no: apk_version.version_no}
  end
end
