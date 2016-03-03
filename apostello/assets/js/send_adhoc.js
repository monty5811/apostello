import $ from 'jquery';
import setCost from './calculate_sms_cost';

$(document).ready(
  () => {
    $('.dropdown').dropdown(
      {
        onChange(text) {
          setCost(text.length);
        },
      }
    );
    $('#id_content').keyup(() => {
      const nPeople = $('.delete.icon').length;
      setCost(nPeople);
    });
  }
);
