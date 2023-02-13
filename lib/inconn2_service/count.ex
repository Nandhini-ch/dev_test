defmodule Inconn2Service.Count do
  alias Inconn2Service.Workorder

  def my_action_count(user, prefix) do
    %{
      work_order: Workorder.list_work_orders_of_user(user, prefix)
    }


  end


end
