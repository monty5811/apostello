import $ from 'jquery';
import { csrfSafeMethod, getCookie, sameOrigin } from './django_cookies';
import { setupSendAdhoc, setupSendGroup } from './send_costs';
import { renderTable } from './render_table';
import { renderElvantoButtons } from './elvanto';
import { renderToggleButton } from './item_remove_button';
import { renderAdminUserForm, renderTestEmailForm, renderTestSmsForm } from './first_run';

/* global _url */

function setupDropdowns() {
  // manually specify all dropdowns to setup:
  const dropdownOptions = {
    label: {
      transition: 'horizontal flip',
      duration: 0,
      variation: false,
    },
  };
  // main menu:
  $('#primary-menu').dropdown(dropdownOptions);
  $('#tools-menu').dropdown(dropdownOptions);
  // create/edit group
  $('#members_dropdown').dropdown(dropdownOptions);
  // create/edit contact
  $('#groups_dropdown').dropdown(dropdownOptions);
  // create/edit keyword
  $('#linked_group_dropdown').dropdown(dropdownOptions);
  $('#owners_dropdown').dropdown(dropdownOptions);
  $('#digest_dropdown').dropdown(dropdownOptions);
  // send sms dropdowns are initialised in send_costs.js
}

function appInit() {
  // setup ajax
  $.ajaxSetup({
    beforeSend(xhr, settings) {
      if (!csrfSafeMethod(settings.type) && sameOrigin(settings.url)) {
        const csrftoken = getCookie('csrftoken');
        xhr.setRequestHeader('X-CSRFToken', csrftoken);
      }
    },
  });

  setupDropdowns();

  // handle live cost estimates
  if (_url === '/send/adhoc/') {
    setupSendAdhoc();
  } else if (_url === '/send/group/') {
    setupSendGroup();
  }
  // render table on page
  if ($('#react_table').length > 0) {
    renderTable();
  }
  // render elvanto buttons
  if ($('#elvanto_pull_button').length > 0) {
    renderElvantoButtons();
  }
  // render remove/restore buttons
  if ($('#toggle_button').length > 0) {
    renderToggleButton();
  }
  // initialise any date pickers
  if ($('#dtBox').length > 0) {
    $('#dtBox').DateTimePicker({
      dateTimeFormat: 'yyyy-MM-dd hh:mm',
      minuteInterval: 5,
      setValueInTextboxOnEveryClick: true,
      buttonsToDisplay: ['SetButton', 'ClearButton'],
    });
  }
  // setup first run page
  if ($('#send_test_email').length > 0) {
    renderTestEmailForm();
  }
  if ($('#send_test_sms').length > 0) {
    renderTestSmsForm();
  }
  if ($('#create_admin_user').length > 0) {
    renderAdminUserForm();
  }
}

$(document).ready(() => appInit());
