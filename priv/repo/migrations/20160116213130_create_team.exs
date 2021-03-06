defmodule Cr2016site.Repo.Migrations.CreateTeam do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :risk_aversion, :integer
      add :notes, :text
      add :user_ids, {:array, :integer}

      timestamps
    end

  end
end
