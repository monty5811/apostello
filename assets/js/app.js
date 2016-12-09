import loadView from './views/loader';
import setupFab from './utils/fab';

function handleDOMContentLoaded() {
  // Get the current view name
  const viewName = document.getElementsByTagName('body')[0].dataset.jsViewName;
  // Load view class and mount it
  const view = loadView(viewName);
  view.mount();
  // setup fab
  setupFab();
}

window.addEventListener('DOMContentLoaded', handleDOMContentLoaded, false);
