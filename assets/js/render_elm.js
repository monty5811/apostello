import Cookies from 'js-cookie';

/* global elmSettings */

function renderElm() {
  const node = document.getElementById('elmContainer');

  if (node !== null) {
    elmSettings.csrftoken = Cookies.get('csrftoken');

    const Elm = require('../elm/Main.elm');
    const app = Elm.Main.embed(node, {
      settings: elmSettings,
    });

    app.ports.scrollIntoView.subscribe(function(id) {
      document.getElementById(id).scrollIntoView({behavior: "auto", block: "start"});
    });

    const loader = document.getElementById('elmLoader');
    if (loader !== null) {
      loader.remove();
    }

    return app;
  }
  return null;
}

export default renderElm;
