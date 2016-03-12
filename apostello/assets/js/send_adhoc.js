import $ from 'jquery';
import setCost from './calculate_sms_cost';

/* global sms_cost */

$(document).ready(
  () => {
    $('.dropdown').dropdown(
      {
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
);
