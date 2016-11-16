const Elm = require('./Main.elm');

function handleDOMContentLoaded() {
  // setup elm
  const node = document.getElementById('elm');
  Elm.Main.embed(node);
}

window.addEventListener('DOMContentLoaded', handleDOMContentLoaded, false);
