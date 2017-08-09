import Cookies from 'js-cookie';
import { isSubscribed, subscribePush, unsubscribePush } from './notifications';

/* global elmSettings */

const lsKey = 'elm-apostello-datastore-v1';

function getDataStoreCache(userEmail) {
  const item = localStorage.getItem(lsKey);
  if (item === null) {
    return null;
  }
  const cache = JSON.parse(item);
  const cachedEmail = cache.userEmail;
  const cacheExpires = cache.expires;
  if (cachedEmail === userEmail && cacheExpires > Date.now()) {
    return JSON.stringify(cache.data);
  }
  return null;
}

function setDataStoreCache(newValue, userEmail) {
  const cacheItem = {
    expires: Date.now() + 600 * 1000,
    userEmail: userEmail,
    data: newValue,
  };
  localStorage.setItem(lsKey, JSON.stringify(cacheItem));
}

function renderElm() {
  const node = document.getElementById('elmContainer');

  if (node !== null) {
    elmSettings.csrftoken = Cookies.get('csrftoken');

    const Elm = require('../elm/Main.elm');
    const app = Elm.Main.embed(node, {
      settings: elmSettings,
      dataStoreCache: getDataStoreCache(elmSettings.userPerms.user.email),
    });

    app.ports.saveDataStore.subscribe(function(data) {
      setDataStoreCache(data, elmSettings.userPerms.user.email);
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

    return app;
  }
  return null;
}

export default renderElm;
