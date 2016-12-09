const fabDropdown = document.getElementsByClassName('fabDropdown')[0];
const fabDim = document.getElementById('fabDim');
const fab = document.getElementById('fab');

function showFab() {
  fabDropdown.style.display = 'block';
  fabDim.className = 'fabDimOn';
}

function hideFab() {
  fabDropdown.style.display = 'none';
  fabDim.className = 'fabDimOff';
}

function fabClick() {
  if (fabDropdown.style.display === 'none') {
    showFab();
  } else {
    hideFab();
  }
}

function dimClick() {
  if (fabDim.className === 'fabDimOn') {
    hideFab();
  }
}

function setupFab() {
  if (fab !== null) {
    fab.addEventListener('click', fabClick);
  }
  if (fabDim !== null) {
    fabDim.addEventListener('click', dimClick);
  }
}

export default setupFab;
