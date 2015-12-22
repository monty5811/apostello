var jQuery = require('jquery');
var semantic = require('./../semantic/dist/semantic.js');

$(document).ready(function() {
$('.dropdown')
  .dropdown({
    onChange: function(text, value) {
      var cost = "$" + 0.04*text.length;
      document.getElementById("#send").innerHTML = "Send (" + cost + ")"
    }});
});