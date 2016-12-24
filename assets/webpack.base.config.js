var path = require("path");
var webpack = require('webpack');

if (process.env.WATCH) {
  elmLoader = 'elm-webpack-loader?debug=true?warn=true';
} else {
  elmLoader = 'elm-webpack-loader';
}

module.exports = {
  context: __dirname,

  entry: {
    app: './js/app',
    tour: './js/tour',
    vendor: [
      'datetimepicker',
      'jquery',
      'inferno-compat',
      'inferno',
      './semantic/dist/components/transition.js',
      './semantic/dist/components/dropdown.js',
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
			'react': 'inferno-compat',
			'react-dom': 'inferno-compat',
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
    }),
    //
    new webpack.optimize.CommonsChunkPlugin({
      name: 'vendor',
      filename: 'vendor.js'
    }),
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
      },
      {
        test: /\.elm?$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: elmLoader,
      }
    ],
  },

  performance: {
    hints: false,
  },

  devtool: 'cheap-module-source-map',
  watchOptions: {
    poll: 500
  }
}
