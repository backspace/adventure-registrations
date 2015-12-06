defmodule Cr2016site.TeamFinder do
  def users_from_email_list(email_list, users) do
    email_list
    |> String.split
    |> Enum.reduce([], fn(email, acc) ->
      user = Enum.find(users, fn(user) -> user.email == email end)
      acc ++ if user, do: [user], else: []
    end)
  end

  def relationships(current_user, users) do
    users_with_current = Enum.filter(users, fn user -> String.contains?(user.team_emails || "", current_user.email) end)
    {mutuals, proposers} = Enum.partition(users_with_current, fn user -> String.contains?(current_user.team_emails || "", user.email) end)

    proposals_by_mutuals = Enum.reduce(mutuals, %{}, fn(user, acc) ->
      user_proposals = users_from_email_list(user.team_emails, users)
      not_mutuals = (user_proposals -- mutuals) -- [current_user]

      proposers_for_this_mutual = Enum.map(not_mutuals, fn(not_mutual) -> {not_mutual, [user]} end)
      |> Enum.into(%{})

      merged = Map.merge(proposers_for_this_mutual, acc, fn(_key, c1, c2) -> c2 ++ c1 end)

      merged
    end)

    %{proposers: proposers, mutuals: mutuals, proposals_by_mutuals: proposals_by_mutuals}
  end
end