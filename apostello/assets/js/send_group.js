import $ from 'jquery';
// const semantic = require('./../semantic/dist/semantic.js');

/* global group_costs */

$(document).ready(() => {
  $('.dropdown')
  .dropdown({
    onChange(text, value) {
      let cost = `\$${group_costs[text]}`;
      if (text === '') {cost = '$0';}
      document.getElementById('#send').innerHTML = `Send (${cost})`;
    },
  });
});
