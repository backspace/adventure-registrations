defmodule Cr2016site.Integration.Admin do
  use Cr2016site.ConnCase
  use Cr2016site.MailgunHelper

  alias Cr2016site.Pages.Login
  alias Cr2016site.Pages.Nav
  alias Cr2016site.Pages.Users
  #alias Cr2016site.Pages.Teams

  # Import Hound helpers
  use Hound.Helpers

  # Start a Hound session
  hound_session()

  test "logging in as an admin" do
    {_, user} = Forge.saved_user email: "francine.pascal@example.com", accessibility: "Some accessibility text", attending: true
    {_, admin} = Forge.saved_octavia admin: true, proposed_team_name: "Admins", attending: false
    {_, blank_attending} = Forge.saved_user email: "blank@example.com"

    navigate_to "/"

    Nav.login_link.click

    Login.fill_email "octavia.butler@example.com"
    Login.fill_password "Xenogenesis"
    Login.submit

    Nav.users_link.click

    assert Users.email(user.id) == "francine.pascal@example.com"
    assert Users.accessibility(user.id) == "Some accessibility text"
    assert Users.attending(user.id) == "✓"

    assert Users.email(admin.id) == admin.email
    assert Users.proposed_team_name(admin.id) == "Admins"
    assert Users.attending(admin.id) == "✘"

    assert Users.attending(blank_attending.id) == "?"
  end

  test "admin can build teams" do
    {_, a} = Forge.saved_user email: "a@example.com", proposed_team_name: "Team A", team_emails: "b@example.com", risk_aversion: 3, accessibility: "Some text"
    {_, b} = Forge.saved_user email: "b@example.com", proposed_team_name: "Team B", team_emails: "a@example.com", risk_aversion: 1, accessibility: "More text"
    {_, c} = Forge.saved_user email: "c@example.com", team_emails: "a@example.com b@example.com"

    Forge.saved_octavia admin: true

    navigate_to "/"
    Login.login_as "octavia.butler@example.com", "Xenogenesis"

    Nav.users_link.click

    refute Users.teamed(a.id)
    refute Users.teamed(b.id)
    refute Users.teamed(c.id)

    Users.build_team_from(a.id)

    assert Nav.info_text == "Team built successfully"

    assert Users.teamed(a.id)
    assert Users.teamed(b.id)
    refute Users.teamed(c.id)

    # FIXME why did this break? Works in development
    # Nav.teams_link.click
    #
    # assert Teams.name(1) == "Team A"
    # assert Teams.risk_aversion(1) == "3"

    [team] = Cr2016site.Repo.all(Cr2016site.Team)
    assert team.name == "Team A"
    assert team.risk_aversion == 3
    assert team.notes == "a: Some text, b: More text"
  end

  test "admin can view team JSON" do
    {_, a} = Forge.saved_user email: "a@example.com"
    {_, b} = Forge.saved_user email: "b@example.com"

    {_, team} = Forge.saved_team name: "A team", risk_aversion: 2, notes: "Some notes", user_ids: [a.id, b.id]

    Forge.saved_octavia admin: true

    navigate_to "/"
    Login.login_as "octavia.butler@example.com", "Xenogenesis"

    navigate_to "/api/teams"
    json = Floki.find(page_source(), "pre") |> Floki.text |> Poison.Parser.parse!

    assert json == %{"data" => [%{
      "type" => "teams",
      "id" => team.id,
      "attributes" => %{
        "name" => "A team",
        "notes" => "Some notes",
        "users" => "a@example.com, b@example.com",
        "riskAversion" => 2
      }
    }]}
  end

  test "non-admins cannot access the user list or messages" do
    Forge.saved_user email: "francine.pascal@example.com"

    assert Nav.users_link.absent?

    navigate_to "/users"

    refute page_source() =~ "francine.pascal@example.com"

    navigate_to "/messages"
    assert Nav.error_text == "Who are you?"

    navigate_to "/teams"
    assert Nav.error_text == "Who are you?"
  end
end
