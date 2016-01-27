defmodule Cr2016site.Pages.Users do
  use Hound.Helpers

  defp user_container(id) do
    "tr[id='user-#{id}']"
  end

  def email(id) do
    visible_text({:css, "#{user_container(id)} .email"})
  end

  def accessibility(id) do
    visible_text({:css, "#{user_container(id)} .accessibility"})
  end

  def proposed_team_name(id) do
    visible_text({:css, "#{user_container(id)} .proposed-team-name"})
  end

  def teamed(id) do
    visible_text({:css, "#{user_container(id)} .teamed"}) == "✓"
  end

  def build_team_from(id) do
    click {:css, "#{user_container(id)} a"}
  end
end