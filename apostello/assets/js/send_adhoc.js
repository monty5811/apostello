import $ from 'jquery';
// var semantic = require('./../semantic/dist/semantic.js');

$(document).ready(
  () => {
    $('.dropdown').dropdown(
      {
        onChange(text, value) {
          const cost = `\$${0.04 * text.length}`;
          document.getElementById('#send').innerHTML = `Send (${cost})`;
        },
      }
    );
  }
);
