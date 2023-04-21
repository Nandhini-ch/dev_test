defmodule Inconn2Service.Communication.MessageTemplates do
  use Ecto.Schema
  import Ecto.Changeset

  schema "message_templates" do
    field :message, :string
    field :template_name, :string
    field :dlt_template_id, :string
    field :telemarketer_id, :string
    field :code, :string

    timestamps()
  end

  @doc false
  def changeset(message_templates, attrs) do
    message_templates
    |> cast(attrs, [:message, :template_name, :dlt_template_id, :telemarketer_id, :code])
    |> validate_required([:message])
  end
end
