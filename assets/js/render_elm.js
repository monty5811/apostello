import Cookies from 'js-cookie';

/* global elmSettings, elmMessages */

const lsKey = 'elm-apostello-datastore-v1';

function getDataStoreCache(userEmail) {
  const item = localStorage.getItem(lsKey);
  if (item === null) {
    return null;
  }
  if (item.userEmail === userEmail && item.expires < Date.now()) {
    return item.data;
  }
  return null;
}

function setDataStoreCache(newValue, userEmail) {
  const cacheItem = {
    expires: Date.now() + 600,
    userEmail,
    data: newValue,
  };
  localStorage.setItem(lsKey, JSON.stringify(cacheItem));
}

function renderElm() {
  const node = document.getElementById('elmContainer');

  if (node !== null) {
    elmSettings.csrftoken = Cookies.get('csrftoken');

    const Elm = require('../elm/Main.elm');
    const app = Elm.Main.embed(node,
      {
        settings: elmSettings,
        messages: elmMessages,
        dataStoreCache: getDataStoreCache(elmSettings.userPerms.user.email),
      },
    );

    app.ports.saveDataStore.subscribe(
      (data) => {
        setDataStoreCache(data, elmSettings.userPerms.user.email);
      },
    );

    window.addEventListener('storage', (event) => {
      if (event.key === lsKey) {
        app.ports.loadDataStore.send(event.newValue);
      }
    });

    return app;
  }
  return null;
}

export default renderElm;
