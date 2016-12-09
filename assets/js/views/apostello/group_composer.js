import CommonView from '../common';

const Elm = require('../../../elm/GroupComposer.elm');

module.exports = class View extends CommonView {
  mount() {
    super.mount();

    // setup elm
    const node = document.getElementById('group_composer');
    Elm.GroupComposer.embed(node);
  }
};
