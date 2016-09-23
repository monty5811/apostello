import $ from 'jquery';
import dropdownOptions from '../../utils/dropdown_options';
import CommonView from '../common';

module.exports = class View extends CommonView {
  mount() {
    super.mount();

    $('#id_auto_add_new_groups').dropdown(dropdownOptions);
  }
};
