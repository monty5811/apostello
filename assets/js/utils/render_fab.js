import Cookies from 'js-cookie';

/* global fabLinks */

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
    Elm.Main.embed(node,
      { pageId: 'fab',
        dataUrl: '',
        csrftoken: Cookies.get('csrftoken'),
        fabData: {
          pageLinks: fabLinks,
          archiveButton: getArchiveButtonData(),
        },
      },
    );
  }
}

export default renderElm;
