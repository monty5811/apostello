var path = require("path");
var webpack = require("webpack");

module.exports = {
  context: __dirname,

  entry: {
    app: "../js/app",
  },

  output: {
    path: path.resolve("../apostello/static/js/"),
    filename: "[name].js"
  },

  resolve: {
    extensions: [".js", ".elm"],
  },

  plugins: [
    new webpack.LoaderOptionsPlugin({
      minimize: true,
      debug: false
    }),
  ],

  module: {
    rules: [
      {
        test: /\.elm?$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: "elm-webpack-loader",
        options: {
          debug: true,
          warn: true,
        },
      }
    ],

    noParse: /\.elm$/
  },

  performance: {
    hints: false
  },

  watchOptions: {
    poll: 500
  },

  mode: 'development',
  optimization: {},
};
