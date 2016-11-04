import { getCookie } from '../js/utils/django_cookies';

const Elm = require('./Main.elm');

function handleDOMContentLoaded() {
  // setup elm
  const node = document.getElementById('elm');
  Elm.Main.embed(node, {
    csrftoken: getCookie('csrftoken'),
  });
}

window.addEventListener('DOMContentLoaded', handleDOMContentLoaded, false);
