var path = require("path");
var webpack = require("webpack");

if (process.env.WATCH) {
  elmLoader = "elm-webpack-loader?debug=true?warn=true";
} else {
  elmLoader = "elm-webpack-loader";
}

module.exports = {
  context: __dirname,

  entry: {
    app: "./js/app",
  },

  output: {
    path: path.resolve("./../apostello/static/js/"),
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
        loader: elmLoader
      }
    ],

    noParse: /\.elm$/
  },

  performance: {
    hints: false
  },

  watchOptions: {
    poll: 500
  }
};
