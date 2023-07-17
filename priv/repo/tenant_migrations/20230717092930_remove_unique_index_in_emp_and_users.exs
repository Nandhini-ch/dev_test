defmodule Inconn2Service.Repo.Migrations.RemoveUniqueIndexInEmpAndUsers do
  use Ecto.Migration

  def change do
      drop_if_exists index("employees", [:email])
      drop_if_exists index("users", [:email])
  end
end
