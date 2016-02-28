import $ from 'jquery';

$(document).ready(() => {
  $('input[name$="_time"]').daterangepicker({
    autoApply: true,
    autoUpdateInput: true,
    format: 'YYYY-MM-DD hh:ss',
    timePicker: true,
    singleDatePicker: true,
    timePickerIncrement: 5,
  });
});
