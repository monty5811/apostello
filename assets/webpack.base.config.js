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
      'localforage',
      'moment',
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
    preLoaders: [
      {
        test: /\.jsx?$/,
        loader: "eslint-loader"
      }
    ],

    loaders: [{
        test: /\.jsx?$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        query: {
          compact: true,
          comments: false,
          presets: ['babel-preset-es2015', 'react']
        }
      }, // to transform JSX into JS
    ],
    // do not include moment locales
    noParse: [/moment.js/],
  },

  devtool: 'source-map',
  watchOptions: {
    poll: 500
  }
}
