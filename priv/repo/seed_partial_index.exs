Inconn2Service.Common.build_timezone_db()
Inconn2Service.DataHandling.SeedData.seed_data()

admin = %{
  "full_name" => "Admin User",
  "username" => "adminuser@inconn.com",
  "password" => "password"
 }
{:ok, admin} = Inconn2Service.Common.create_admin_user(admin)
