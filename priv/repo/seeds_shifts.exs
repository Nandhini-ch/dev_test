alias Inconn2Service.Settings

{:ok, shiftstarttime1} = Time.new(09, 00, 00)
{:ok, shiftendtime1} = Time.new(18, 00, 00)
{:ok, shiftstarttime2} = Time.new(06, 00, 00)
{:ok, shiftendtime2} = Time.new(14, 00, 00)
{:ok, shiftstarttime3} = Time.new(14, 00, 00)
{:ok, shiftendtime3} = Time.new(22, 00, 00)
{:ok, shiftstarttime4} = Time.new(22, 00, 00)
{:ok, shiftendtime4} = Time.new(04, 00, 00)


{:ok, shiftstartdate1} = Date.new(2021, 08, 01)
{:ok, shiftenddate1} = Date.new(2022, 08, 30)

{:ok, shiftstartdate2} = Date.new(2021, 08, 20)
{:ok, shiftenddate2} = Date.new(2022, 08, 21)

{:ok, shiftstartdate3} = Date.new(2021, 08, 23)
{:ok, shiftenddate3} = Date.new(2022, 08, 24)

{:ok, shiftstartdate4} = Date.new(2021, 08, 01)
{:ok, shiftenddate4} = Date.new(2022, 08, 30)


shift1 = %{"name" => "shift1", "start_date" => shiftstartdate1, "end_date" => shiftenddate1,
"start_time" => shiftstarttime1, "end_time" => shiftendtime1, "applicable_days" => [1,2,3,4,5], "site_id" => 1}

shift2 = %{"name" => "shift2", "start_date" => shiftstartdate2, "end_date" => shiftenddate2,
"start_time" => shiftstarttime2, "end_time" => shiftendtime2, "applicable_days" => [1,2,3,4,5], "site_id" => 1}

shift3 = %{"name" => "shift3", "start_date" => shiftstartdate3, "end_date" => shiftenddate3,
"start_time" => shiftstarttime3, "end_time" => shiftendtime3, "applicable_days" => [1,2,3,4,5], "site_id" => 1}

shift4 = %{"name" => "shift4", "start_date" => shiftstartdate4, "end_date" => shiftenddate4,
"start_time" => shiftstarttime4, "end_time" => shiftendtime4, "applicable_days" => [6,7], "site_id" => 1}

IO.inspect(Settings.create_shift(shift1,"inc_bata"))
IO.inspect(Settings.create_shift(shift2,"inc_bata"))
IO.inspect(Settings.create_shift(shift3,"inc_bata"))
IO.inspect(Settings.create_shift(shift4,"inc_bata"))


IO.inspect(Inconn2Service.Settings.list_shifts(1,"inc_bata"))

IO.inspect(Inconn2Service.Settings.get_shift!(1,"inc_bata"))

{:ok, checkdate} = Date.new(2021, 08, 19)
IO.inspect(Inconn2Service.Settings.list_shifts_for_a_day(1,checkdate,"inc_bata"))
