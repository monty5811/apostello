import loadView from './views/loader';

function handleDOMContentLoaded() {
  // Get the current view name
  const viewName = document.getElementsByTagName('body')[0].dataset.jsViewName;
  // Load view class and mount it
  const view = loadView(viewName);
  view.mount();
}

window.addEventListener('DOMContentLoaded', handleDOMContentLoaded, false);
