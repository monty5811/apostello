import $ from 'jquery';

function initDateTimePickers(elmApp) {
  if ($('#dtBox').length > 0) {
    $('#dtBox').DateTimePicker({
      dateTimeFormat: 'yyyy-MM-dd hh:mm',
      minuteInterval: 5,
      setValueInTextboxOnEveryClick: true,
      buttonsToDisplay: ['SetButton', 'ClearButton'],
      settingValueOfElement: sValue => {
        if (elmApp !== null) {
          elmApp.ports.updateDateValue.send(sValue);
        }
      },
    });
  }
}

export default initDateTimePickers;
