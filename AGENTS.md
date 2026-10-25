# Repository instructions

## Project

Oliya is an Elixir/Phoenix application that serves OHLCV market data over HTTP and WebSocket. It stores data in PostgreSQL/TimescaleDB and TectonicDB.

Key paths:

- `lib/oliya/` — application and storage backends
- `lib/oliya_web/` — Phoenix endpoint, router, controllers, and views
- `config/` — environment configuration
- `priv/repo/migrations/` — PostgreSQL migrations
- `assets/` — Vue 2 frontend assets
- `test/` — ExUnit tests and support modules

## Setup

Use the Erlang, Elixir, and Node.js versions pinned in `.tool-versions`.

```sh
docker compose up -d
mix setup
```

`mix setup` installs Elixir and JavaScript dependencies and prepares the development database. Do not replace `npm ci` with `npm install`; the lockfile is the reproducible source of truth.

## Validation

Run the complete local/CI gate before committing:

```sh
bin/check
```

The command starts required services, waits for them to become ready, prepares the test database, compiles with warnings as errors, checks formatting, runs the test suite, and runs Dialyzer.

For a focused test:

```sh
MIX_ENV=test mix test path/to/test.exs
```

## Conventions

- Format Elixir with `mix format`.
- Add or update focused ExUnit coverage for behavior changes.
- Keep storage-specific logic in the existing `Oliya.Backend.Postgres` or `Oliya.Backend.Tectonicdb` namespaces.
- Do not edit generated dependencies in `deps/`, build output in `_build/`, or installed packages in `assets/node_modules/`.
- Do not change `.tool-versions`, dependency lockfiles, deployment configuration, or secrets unless the task requires it.
- Preserve unrelated worktree changes and keep commits scoped to the requested task.
