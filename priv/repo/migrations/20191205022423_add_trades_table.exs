defmodule Oliya.Repo.Migrations.AddTradesTable do
  use Ecto.Migration

  def change do
    create table(:trades) do
      add(:venue, :string, null: false)
      add(:symbol, :string, null: false)
      add(:price, :decimal, null: false)
      add(:volume, :decimal, null: false)
      add(:timestamp, :utc_datetime_usec, null: false)
      add(:side, :boolean, null: false)
      add(:venue_trade_id, :string)

      timestamps()
    end

    create(index(:trades, [:venue, :symbol, :timestamp]))
    create(index(:trades, [:venue, :timestamp]))
    create(index(:trades, [:timestamp]))
  end
end
