defmodule Cr2016site.ChannelCase do
  @moduledoc """
  This module defines the test case to be used by
  channel tests.

  Such tests rely on `Phoenix.ChannelTest` and also
  imports other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with channels
      use Phoenix.ChannelTest

      alias Cr2016site.Repo
      import Ecto.Model
      import Ecto.Query, only: [from: 2]


      # The default endpoint for testing
      @endpoint Cr2016site.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Cr2016site.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Cr2016site.Repo, {:shared, self()})
    end

    :ok
  end
end
