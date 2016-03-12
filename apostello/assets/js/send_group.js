import $ from 'jquery';
import setCost from './calculate_sms_cost';

/* global group_sizes, sms_cost */

$(document).ready(
  () => {
    $('.dropdown').dropdown(
      {
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
);
