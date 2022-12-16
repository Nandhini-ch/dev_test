defmodule Inconn2ServiceWeb.WorkrequestFeedbackView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.WorkrequestFeedbackView

  def render("index.json", %{workrequest_feedbacks: workrequest_feedbacks}) do
    %{data: render_many(workrequest_feedbacks, WorkrequestFeedbackView, "workrequest_feedback.json")}
  end

  def render("show.json", %{workrequest_feedback: workrequest_feedback}) do
    %{data: render_one(workrequest_feedback, WorkrequestFeedbackView, "workrequest_feedback.json")}
  end

  def render("workrequest_feedback.json", %{workrequest_feedback: workrequest_feedback}) do
    %{id: workrequest_feedback.id,
      work_request_id: workrequest_feedback.work_request_id,
      user_id: workrequest_feedback.user_id,
      email: workrequest_feedback.email,
      site_id: workrequest_feedback.site_id,
      rating: workrequest_feedback.rating}
  end
end
