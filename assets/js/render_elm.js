import Cookies from 'js-cookie';
import { isSubscribed, subscribePush, unsubscribePush } from './notifications';

/* global elmSettings */

function renderElm() {
  const node = document.getElementById('elmContainer');

  if (node !== null) {
    elmSettings.csrftoken = Cookies.get('csrftoken');

    const Elm = require('../elm/Main.elm');
    const app = Elm.Main.embed(node, {
      settings: elmSettings,
    });

    app.ports.pushSubEvent.subscribe(function(event) {
      if (event === 'check') {
        isSubscribed(app.ports.acceptPushSub);
      } else if (event === 'register') {
        subscribePush(app.ports.acceptPushSub);
      } else if (event === 'unregister') {
        unsubscribePush(app.ports.acceptPushSub);
      }
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
