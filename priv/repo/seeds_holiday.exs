alias Inconn2Service.Settings



{:ok, shiftstartdate1} = Date.new(2021, 08, 01)
{:ok, shiftenddate1} = Date.new(2021, 08, 30)

{:ok, shiftstartdate2} = Date.new(2021, 08, 20)
{:ok, shiftenddate2} = Date.new(2021, 08, 21)

{:ok, shiftstartdate3} = Date.new(2021, 01, 01)
{:ok, shiftenddate3} = Date.new(2021, 01, 04)

{:ok, shiftstartdate4} = Date.new(2019, 08, 01)
{:ok, shiftenddate4} = Date.new(2019, 08, 30)


holiday1 = %{"name" => "mountain day", "start_date" => shiftstartdate1, "end_date" => shiftenddate1, "site_id" => 1}

holiday2 = %{"name" => "obon holidays", "start_date" => shiftstartdate2, "end_date" => shiftenddate2,"site_id" => 1}

holiday3 = %{"name" => "new year ", "start_date" => shiftstartdate3, "end_date" => shiftenddate3,"site_id" => 1}

holiday4 = %{"name" => "obon holidays", "start_date" => shiftstartdate4, "end_date" => shiftenddate4,"site_id" => 1}

IO.inspect(Settings.create_holiday(holiday1,"inc_bata"))
IO.inspect(Settings.create_holiday(holiday2,"inc_bata"))
IO.inspect(Settings.create_holiday(holiday3,"inc_bata"))
IO.inspect(Settings.create_holiday(holiday4,"inc_bata"))

IO.inspect(Inconn2Service.Settings.get_holiday!(1,"inc_bata"))

{:ok, startdate} = Date.new(2019, 01, 01)
{:ok, enddate} = Date.new(2019, 12, 31)
IO.inspect(Inconn2Service.Settings.list_bankholidays(1,startdate,enddate,"inc_bata"))
