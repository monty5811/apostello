var tailwindcss = require('tailwindcss');

module.exports = {
  plugins: [
    require("postcss-import"),
    tailwindcss('./config/tailwind.js'),
    require('autoprefixer'),
    require('cssnano'),
  ]
}
