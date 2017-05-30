import renderElm from './render_elm';

function handleDOMContentLoaded() {
  // start elm
  const elmApp = renderElm();
}

window.addEventListener('DOMContentLoaded', handleDOMContentLoaded, false);

if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js');
  });
}
