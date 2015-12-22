var jQuery = require('jquery');
var semantic = require('./../semantic/dist/semantic.js');

$(document).ready(function() {
$('.dropdown')
  .dropdown({
    onChange: function(text, value) {
      if (text==="") {var cost = "$0"} else {var cost = "$" + group_costs[text]};
      document.getElementById("#send").innerHTML = "Send (" + cost + ")"
    }});
});