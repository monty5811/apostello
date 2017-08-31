import Cookies from 'js-cookie';
import { isSubscribed, subscribePush, unsubscribePush } from './notifications';

/* global elmSettings */

const lsKey = 'elm-apostello-datastore-v2';

function setDataStoreCache(newValue) {
  const cacheItem = {
    expires: Date.now() + 600 * 1000,
    data: newValue,
  };
  localStorage.setItem(lsKey, JSON.stringify(cacheItem));
  // remove again as we don't need to keep it around
  // and the set value is passed to the event handler in the other tabs
  localStorage.removeItem(lsKey);
}

function renderElm() {
  const node = document.getElementById('elmContainer');

  if (node !== null) {
    elmSettings.csrftoken = Cookies.get('csrftoken');

    const Elm = require('../elm/Main.elm');
    const app = Elm.Main.embed(node, {
      settings: elmSettings,
    });

    app.ports.saveDataStore.subscribe(function(data) {
      setDataStoreCache(data);
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

    window.addEventListener('storage', function(event) {
      if (event.key === lsKey) {
        app.ports.loadDataStore.send(event.newValue);
      }
    });

    const loader = document.getElementById('elmLoader');
    loader.remove();

    return app;
  }
  return null;
}

export default renderElm;
