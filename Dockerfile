# Find eligible builder and runner images on Docker Hub. We use Debian
# instead of Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=debian
# https://hub.docker.com/_/debian?tab=tags
#
# This file is based on these images:
#
#   - https://hub.docker.com/_/node - for the asset build image
#   - https://hub.docker.com/r/hexpm/elixir/tags - for the application build image
#   - https://hub.docker.com/_/debian?tab=tags - for the release image
#
ARG ELIXIR_VERSION=1.20.4
ARG OTP_VERSION=29.1.2
ARG NODE_VERSION=26.12.1
ARG DEBIAN_VERSION=bookworm-20261020-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM node:${NODE_VERSION}-bookworm-slim AS assets

WORKDIR /app/assets
COPY assets/package.json assets/package-lock.json ./
RUN npm ci
COPY assets ./
RUN npm run build

FROM ${BUILDER_IMAGE} as builder

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN --mount=type=secret,id=SECRET_KEY_BASE SECRET_KEY_BASE="$(cat /run/secrets/SECRET_KEY_BASE)" mix deps.compile

COPY priv priv
COPY --from=assets /app/priv/static priv/static

COPY lib lib

RUN --mount=type=secret,id=SECRET_KEY_BASE SECRET_KEY_BASE="$(cat /run/secrets/SECRET_KEY_BASE)" mix phx.digest

# Compile the release
RUN --mount=type=secret,id=SECRET_KEY_BASE SECRET_KEY_BASE="$(cat /run/secrets/SECRET_KEY_BASE)" mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
RUN --mount=type=secret,id=SECRET_KEY_BASE SECRET_KEY_BASE="$(cat /run/secrets/SECRET_KEY_BASE)" mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/oliya ./

USER nobody

CMD ["/app/bin/server"]

# Appended by flyctl
ENV ECTO_IPV6 true
ENV ERL_AFLAGS "-proto_dist inet6_tcp"
