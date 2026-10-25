const mix = require('laravel-mix');
const path = require('path');
mix.setPublicPath('../priv/static')
  .js('js/app.js', 'js/app.js')
  .vue()
  .extract(Object.keys(require('./package.json').dependencies))
  .sass('css/app.scss', 'css/app.css')
  .version()
  .copyDirectory('./static', '../priv/static')
  .webpackConfig({
    resolve: {
      extensions: ['.vue', '.js'],
      alias: {
        '@': path.resolve(__dirname, 'js')
      }
    }
  })
  .options({
    clearConsole: false,
    processCssUrls: false
  });
