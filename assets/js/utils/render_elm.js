import biu from 'biu.js';
import Cookies from 'js-cookie';

function renderElm() {
  const node = document.getElementById('elmContainer');

  if (node !== null) {
    let pageId = node.getAttribute('pageid');
    if (pageId === null) {
      pageId = document.getElementsByTagName('body')[0].dataset.jsViewName;
    }

    const Elm = require('../../elm/Main.elm');
    const app = Elm.Main.embed(node,
      { pageId,
        dataUrl: node.getAttribute('src'),
        csrftoken: Cookies.get('csrftoken'),
        fabData: null,
      },
    );
    // setup ports
    app.ports.showMessage.subscribe(
      msg => biu(msg.content, { type: msg.msgType, autoHide: false }),
    );
  }
}

export default renderElm;
