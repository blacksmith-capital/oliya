# Oliya - Oil

Oliya is a tool for collecting financial data and providing OHLCV data through HTTP and WebSocket.

Oliya is a Phoenix app built with [tai](https://github.com/fremantle-capital/tai). It is intended to be used in conjunction with [Likhtar](https://github.com/blacksmith-capital/likhtar) - financial data charting tool.

[![Build Status](https://github.com/blacksmith-capital/oliya/workflows/Test/badge.svg)](https://github.com/blacksmith-capital/oliya/actions?query=workflow%3ATest)

## Development

Install the tool versions from `.tool-versions`, then set up the application:

```sh
docker compose up -d
mix setup
mix phx.server
```

Visit [`localhost:4000`](http://localhost:4000) in your browser.

Run the same validation used by CI before committing:

```sh
bin/check
```

# Deploy to fly.io

* `fly launch`
* `fly deploy --build-secret SECRET_KEY_BASE="GENERATED_SECRET"`

# TODO

- [ ] Extract `Oliya` into standalone pluggable package

## Authors

* [Yuri Koval'ov](https://www.yurikoval.com/) - hello@yurikoval.com
