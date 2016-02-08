var path = require("path");
var webpack = require('webpack');
var BundleTracker = require('webpack-bundle-tracker');

module.exports = {
  context: __dirname,

  entry: {
    main: './js/main',
    send_adhoc: './js/send_adhoc',
    send_group: './js/send_group',
    incoming_table: './js/incoming_table',
    outgoing_table: './js/outgoing_table',
    contacts_table: './js/contacts_table',
    contacts_recent_sms_table: './js/contacts_recent_sms_table',
    groups_table: './js/groups_table',
    keywords_table: './js/keywords_table',
    keyword_resp_table: './js/keyword_resp_table',
    elvanto: './js/elvanto',
    curate_container: './js/curate_container',
    item_remove_button: './js/item_remove_button',

    daterangepicker: './js/daterangepicker',
    vendor: ['jquery',
      'moment',
      'react',
      'react-dom',
      './semantic/dist/semantic.js'
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
    // removes a lot of debugging code in React
    new webpack.DefinePlugin({
      'process.env': {
        'NODE_ENV': JSON.stringify('production')
      }
    }),
    //
    new webpack.optimize.CommonsChunkPlugin("vendor", "vendor.bundle.js"),
    // minifies code
    new webpack.optimize.UglifyJsPlugin({
      compressor: {
        warnings: false
      }
    }),
    //
    new webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery"
    })
  ],

  module: {
    loaders: [{
        test: /\.jsx?$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        query: {
          compact: true,
          comments: false,
          presets: ['react', 'es2015']
        }
      }, // to transform JSX into JS
    ],
  },

  resolve: {
    modulesDirectories: ['node_modules'],
    extensions: ['', '.js', '.jsx']
  },
  watchOptions: {
    poll: 500
  }
}
