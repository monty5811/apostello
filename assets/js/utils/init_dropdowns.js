import $ from 'jquery';
import dropdownOptions from './dropdown_options';
import setCost from './calculate_sms_cost';

/* global group_sizes, sms_cost */

function initDropdowns() {
  // create/edit recipient page:
  $('#groups_dropdown').dropdown(dropdownOptions);
  // create/edit keyword page:
  $('#linked_group_dropdown').dropdown(dropdownOptions);
  $('#owners_dropdown').dropdown(dropdownOptions);
  $('#digest_dropdown').dropdown(dropdownOptions);
  // edit config page:
  $('#id_auto_add_new_groups').dropdown(dropdownOptions);
  // send adhoc page
  $('#id_recipients').dropdown(
    {
      forceSelection: false,
      fullTextSearch: true,
      onChange(text) {
        setCost(text.length, sms_cost);
      },
    },
  );
  // send group page
  $('#id_recipient_group').dropdown(
    {
      fullTextSearch: true,
      onChange(text) {
        setCost(group_sizes[text], sms_cost);
      },
    },
  );
}

export default initDropdowns;
