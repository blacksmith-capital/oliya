defmodule Oliya.Support.WithSharedRepo do
  use ExUnit.CaseTemplate
  alias Oliya.Backend.Postgres.Repo

  setup do
    old_backend = Application.get_env(:oliya, :backend)
    Application.put_env(:oliya, :backend, Oliya.Backend.Postgres)
    Application.ensure_all_started(:oliya)

    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    on_exit(fn ->
      Application.put_env(:oliya, :backend, old_backend)
    end)

    :ok
  end

  using do
    quote do
      alias Oliya.Backend.Postgres.Repo
    end
  end
end
