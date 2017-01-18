import Cookies from 'js-cookie';

/* global fabLinks */

function redirect(url) {
  window.location.href = url;
}

function getArchiveButtonData() {
  const buttonDiv = document.getElementById('toggle_button');
  if (buttonDiv === null) {
    return null;
  }
  return {
    postUrl: buttonDiv.getAttribute('postUrl'),
    redirectUrl: buttonDiv.getAttribute('redirectUrl'),
    isArchived: JSON.parse(buttonDiv.getAttribute('isArchived')),
  };
}

function renderElm() {
  const node = document.getElementById('fabContainer');

  if (node !== null) {
    const Elm = require('../../elm/Main.elm');
    const app = Elm.Main.embed(node,
      { pageId: 'fab',
        dataUrl: '',
        csrftoken: Cookies.get('csrftoken'),
        fabData: {
          pageLinks: fabLinks,
          archiveButton: getArchiveButtonData(),
        },
      },
    );
    // setup ports
    app.ports.redirectToUrl.subscribe(url => redirect(url));
  }
}

export default renderElm;
