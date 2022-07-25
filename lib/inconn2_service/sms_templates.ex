defmodule Inconn2Service.SmsTemplates do
  def forgot_password_template(otp) do
    "Hi, Your OTP for restting your InConn Password is #{otp}"
  end
end
