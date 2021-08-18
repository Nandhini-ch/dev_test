defmodule Inconn2ServiceWeb.AddressContactView do
  use Inconn2ServiceWeb, :view



  def render("address.json", %{address_contact: address_contact}) do
    %{
      address_line1: address_contact.address_line1,
      address_line2: address_contact.address_line2,
      city: address_contact.city,
      state: address_contact.state,
      country: address_contact.country,
      postcode: address_contact.postcode
    }
  end

  def render("contact.json", %{address_contact: address_contact}) do
    %{
      first_name: address_contact.first_name,
      last_name: address_contact.last_name,
      designation: address_contact.designation,
      email: address_contact.email,
      land_line: address_contact.land_line,
      mobile: address_contact.mobile
    }
  end

end
