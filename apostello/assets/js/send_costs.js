import $ from 'jquery';
import setCost from './calculate_sms_cost';

/* global group_sizes, sms_cost */

function setupSendAdhoc() {
  // handle send adhoc cost updates
  $('.field .dropdown').dropdown(
    {
      fullTextSearch: true,
      onChange(text) {
        setCost(text.length, sms_cost);
      },
    }
  );
  $('#id_content').keyup(() => {
    const nPeople = $('.delete.icon').length;
    setCost(nPeople, sms_cost);
  });
}

function setupSendGroup() {
  // handle send group cost updates
  $('.field .dropdown').dropdown(
    {
      fullTextSearch: true,
      onChange(text) {
        setCost(group_sizes[text], sms_cost);
      },
    }
  );
  $('#id_content').keyup(() => {
    let nPeople = 0;
    const selectedGroup = $('.item.active.selected')[0];
    if (selectedGroup !== undefined) {
      nPeople = group_sizes[selectedGroup.getAttribute('data-value')];
    }
    setCost(nPeople, sms_cost);
  });
}

export { setupSendAdhoc, setupSendGroup };
