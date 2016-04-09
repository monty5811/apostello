import $ from 'jquery';
import { csrfSafeMethod, getCookie, sameOrigin } from './django_cookies';
import { setupSendAdhoc, setupSendGroup } from './send_costs';
import { renderTable } from './render_table';
import { renderElvantoButtons } from './elvanto';
import { renderToggleButton } from './item_remove_button';

/* global _url */

// use django cookie for all ajax calls
$.ajaxSetup({
  beforeSend(xhr, settings) {
    if (!csrfSafeMethod(settings.type) && sameOrigin(settings.url)) {
      const csrftoken = getCookie('csrftoken');
      xhr.setRequestHeader('X-CSRFToken', csrftoken);
    }
  },
});

$(document).ready(() => {
  // initialise dropdown menus
  $('.dropdown').dropdown({
    label: {
      transition: 'horizontal flip',
      duration: 0,
      variation: false,
    },
  });
});

$(document).ready(() => {
  // handle live cost estimates
  if (_url === '/send/adhoc/') {
    setupSendAdhoc();
  } else if (_url === '/send/group/') {
    setupSendGroup();
  }
});

$(document).ready(() => {
  // render table on page
  if ($('#react_table').length > 0) {
    renderTable();
  }
});

$(document).ready(() => {
  // render elvanto buttons
  if ($('#elvanto_pull_button').length > 0) {
    renderElvantoButtons();
  }
});

$(document).ready(() => {
  // render remove/restore buttons
  if ($('#toggle_button').length > 0) {
    renderToggleButton();
  }
});

$(document).ready(() => {
  // initialise any date pickers
  $('#dtBox').DateTimePicker({
    dateTimeFormat: 'yyyy-MM-dd hh:mm',
    minuteInterval: 5,
    setValueInTextboxOnEveryClick: true,
    buttonsToDisplay: ['SetButton', 'ClearButton'],
  });
});
