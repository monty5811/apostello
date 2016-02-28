import $ from 'jquery';

$(document).ready(() => {
  $('#dtBox').DateTimePicker({
    dateTimeFormat: 'yyyy-MM-dd hh:mm',
    minuteInterval: 5,
    setValueInTextboxOnEveryClick: true,
    buttonsToDisplay: ['SetButton', 'ClearButton'],
  });
});
