import renderElm from './render_elm';
import initDateTimePickers from './init_dt';
import initDropdowns from './init_dropdowns';

function handleDOMContentLoaded() {
  // init dropdowns
  initDropdowns();
  // start elm
  const elmApp = renderElm();
  // init datepickers
  initDateTimePickers(elmApp);
}

window.addEventListener('DOMContentLoaded', handleDOMContentLoaded, false);

if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js');
  });
}
