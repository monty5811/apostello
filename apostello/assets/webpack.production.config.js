var path = require("path");
var webpack = require('webpack');
var config = require('./webpack.base.config.js');


config.plugins = config.plugins.concat([
  // removes a lot of debugging code in React
  new webpack.DefinePlugin({
    'process.env': {
      'NODE_ENV': JSON.stringify('production')
    }
  }),
  //
  new webpack.optimize.CommonsChunkPlugin({
    name: 'vendor', 
    filename: 'vendor.js'
  }),
  // minifies code
  new webpack.optimize.UglifyJsPlugin({
    compress: {
      warnings: false
    },
    output: {
      comments: false
    }
  })
]);

module.exports = config;
