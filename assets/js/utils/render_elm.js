import Cookies from 'js-cookie';

function renderElm() {
  const node = document.getElementById('elmContainer');

  if (node !== null) {
    let pageId = node.getAttribute('pageid');
    if (pageId === null) {
      pageId = document.getElementsByTagName('body')[0].dataset.jsViewName;
    }

    const Elm = require('../../elm/Main.elm');
    Elm.Main.embed(node,
      { pageId,
        dataUrl: node.getAttribute('src'),
        csrftoken: Cookies.get('csrftoken'),
        fabData: null,
      },
    );
  }
}

export default renderElm;
