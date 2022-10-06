defmodule Inconn2ServiceWeb.ReferenceTemplateDownloaderController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.ReferenceTemplateDownloader
  action_fallback Inconn2ServiceWeb.FallbackController
end
