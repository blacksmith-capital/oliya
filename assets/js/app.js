// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
// import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
// import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import Vue from 'vue';
import BootstrapVue from 'bootstrap-vue';
import axios from 'axios';
import Likhtar from 'likhtar';

const moment = require('moment');
const _ = require('lodash');

Vue.use(BootstrapVue);
Vue.component(Likhtar.name, Likhtar);

const token = document.head.querySelector('meta[name="csrf-token"]');
if (token) {
  axios.defaults.headers.common['X-CSRF-TOKEN'] = token.content;
}

new Vue({
  el: '#app',
  data: {
    symbols: 'BITMEX:XBTUSD,BINANCE:BTC_USDT',
    granularity: '1m',
    series: [
      { id: "BITMEX-XBTUSD", type: "ohlc"},
      { id: "BINANCE-BTC_USDT", type: "candlestick"}
    ]
  }
});
