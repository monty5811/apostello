var config = require('./webpack.base.config.js');

config.mode = 'production';
config.module.rules = [
  {
    test: /\.elm?$/,
    exclude: [/elm-stuff/, /node_modules/],
    loader: "elm-webpack-loader",
    options: {},
  }
];

module.exports = config;
