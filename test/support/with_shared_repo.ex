defmodule Oliya.Support.WithSharedRepo do
  use ExUnit.CaseTemplate
  alias Oliya.Repo

  setup do
    Application.ensure_all_started(:oliya)

    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  using do
    quote do
      alias Oliya.Repo
    end
  end
end
