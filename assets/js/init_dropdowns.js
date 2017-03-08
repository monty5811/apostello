import $ from 'jquery';

const dropdownOptions = {
  label: {
    transition: 'horizontal flip',
    duration: 0,
    variation: false,
  },
};

function initDropdowns() {
  // create/edit recipient page:
  $('#groups_dropdown').dropdown(dropdownOptions);
  // create/edit keyword page:
  $('#linked_group_dropdown').dropdown(dropdownOptions);
  $('#owners_dropdown').dropdown(dropdownOptions);
  $('#digest_dropdown').dropdown(dropdownOptions);
  // edit config page:
  $('#id_auto_add_new_groups').dropdown(dropdownOptions);
}

export default initDropdowns;
