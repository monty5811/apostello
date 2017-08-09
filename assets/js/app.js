import renderElm from './render_elm';

function handleDOMContentLoaded() {
  // start elm
  try {
    const elmApp = renderElm();
  } catch (e) {
    console.err(e);
    const node = document.getElementById('elmContainer');
    const style =
      'width:100vw;height:100vh;background:#5a589b;color:#fff;font-size:xx-large;';
    node.innerHTML =
      '<div style="' +
      style +
      '"><p>Something broke there, try reloading the page...</p></div>' +
      '<br></br>' +
      '<br></br>' +
      '<br></br>' +
      e;
  }
}

window.addEventListener('DOMContentLoaded', handleDOMContentLoaded, false);

if ('serviceWorker' in navigator) {
  window.addEventListener('load', function() {
    navigator.serviceWorker.register('/sw.js');
  });
}
