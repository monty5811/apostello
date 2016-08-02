import $ from 'jquery';

function initDateTimePickers() {
  if ($('#dtBox').length > 0) {
    $('#dtBox').DateTimePicker({
      dateTimeFormat: 'yyyy-MM-dd hh:mm',
      minuteInterval: 5,
      setValueInTextboxOnEveryClick: true,
      buttonsToDisplay: ['SetButton', 'ClearButton'],
    });
  }
}

export default initDateTimePickers;
