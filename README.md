# Oliya - Oil

Oliya is a tool for collecting financial data and providing OHLCV data through HTTP and WebSocket.

Oliya is a Phoenix app built with [tai](https://github.com/fremantle-capital/tai). It is intended to be used in conjunction with [Likhtar](https://github.com/blacksmith-capital/likhtar) - financial data charting tool.

[![Build Status](https://github.com/blacksmith-capital/oliya/workflows/Test/badge.svg)](https://github.com/blacksmith-capital/oliya/actions?query=workflow%3ATest)

To start your Phoenix server:

  * Install dependencies with `mix deps`
  * Run setup `mix setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

# Deploy to fly.io

* `fly launch`
* `fly deploy --build-secret SECRET_KEY_BASE="GENERATED_SECRET"`

# TODO

- [ ] Extract `Oliya` into standalone pluggable package

## Authors

* [Yuri Koval'ov](https://www.yurikoval.com/) - hello@yurikoval.com
