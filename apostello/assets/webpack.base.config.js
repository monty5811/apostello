var path = require("path");
var webpack = require('webpack');

module.exports = {
  context: __dirname,

  entry: {
    main: './js/main',
    tour: './js/tour',
    vendor: [
      'jquery',
      'datetimepicker',
      'react',
      'react-dom',
      './semantic/dist/semantic.js',
    ]
  },

  output: {
    path: path.resolve('./../static/js/'),
    filename: "[name].js",
  },

  resolve: {
    alias: {
      jquery: "jquery/src/jquery"
    }
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
          presets: ['babel-preset-es2015-webpack', 'react']
        }
      }, // to transform JSX into JS
    ],
  },

  resolve: {
    modulesDirectories: ['node_modules'],
    extensions: ['', '.js', '.jsx']
  },
  devtool: 'source-map',
  watchOptions: {
    poll: 500
  }
}
