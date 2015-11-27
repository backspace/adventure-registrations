defmodule Cr2016site.IntegrationTest do
  use Cr2016site.ConnCase

  # Import Hound helpers
  use Hound.Helpers

  # Start a Hound session
  hound_session

  test "GET /" do
    Forge.saved_user email: "francine.pascal@example.com"

    navigate_to "/"
    assert page_source =~ "Clandestine Rendezvous"

    assert page_source =~ "francine.pascal@example.com"
  end

  test "registering" do
    navigate_to "/"
    click({:link_text, "Register"})

    fill_field({:id, "email"}, "samuel.delaney@example.com")
    fill_field({:id, "password"}, "nestofspiders")
    click({:class, "btn"})

    assert visible_text({:css, ".alert-info"}) == "Your account was created"
    assert page_source =~ "samuel.delaney@example.com"
  end
end
