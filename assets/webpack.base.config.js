var path = require("path");
var webpack = require('webpack');

module.exports = {
  context: __dirname,

  entry: {
    app: './js/app',
    tour: './js/tour',
    vendor: [
      'datetimepicker',
      'jquery',
      'react',
      'react-dom',
      './semantic/dist/semantic.js',
    ]
  },

  output: {
    path: path.resolve('./../apostello/static/js/'),
    filename: "[name].js",
  },

  resolve: {
    extensions: ['.js', '.jsx'],
    alias: {
      jquery: 'jquery/src/jquery',
    },
  },

  plugins: [
		new webpack.LoaderOptionsPlugin({
			minimize: true,
			debug: false
		}),
    //
    new webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery"
    })
  ],

  module: {
    rules: [
      {
        enforce: 'pre',
        test: /\.jsx?$/,
        loader: "eslint-loader"
      },
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
      }
    ],
  },

  devtool: 'cheap-module-source-map',
  watchOptions: {
    poll: 500
  }
}
