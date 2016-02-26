import $ from 'jquery';

function getCookie(name) {
  let cookieValue = null;
  if (document.cookie && document.cookie !== '') {
    const cookies = document.cookie.split(';');
    for (let i = 0; i < cookies.length; i++) {
      const cookie = $.trim(cookies[i]);
      // Does this cookie string begin with the name we want?
      if (cookie.substring(0, name.length + 1) === (`${name}=`)) {
        cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
        break;
      }
    }
  }
  return cookieValue;
}

function csrfSafeMethod(method) {
  // these HTTP methods do not require CSRF protection
  return (/^(GET|HEAD|OPTIONS|TRACE)$/.test(method));
}

function sameOrigin(url) {
  const host = document.location.host; // host + port
  const protocol = document.location.protocol;
  const srOrigin = `//${host}`;
  const origin = protocol + srOrigin;
  // Allow absolute or scheme relative URLs to same origin
  return (url === origin || url.slice(0, origin.length + 1) === `${origin}/`) ||
    (url === srOrigin || url.slice(0, srOrigin.length + 1) === `${srOrigin}/`) ||
      // or any other URL that isn't scheme relative or absolute i.e relative.
      !(/^(\/\/|http:|https:).*/.test(url));
}

$.ajaxSetup({
  beforeSend(xhr, settings) {
    if (!csrfSafeMethod(settings.type) && sameOrigin(settings.url)) {
      const csrftoken = getCookie('csrftoken');
      xhr.setRequestHeader('X-CSRFToken', csrftoken);
    }
  },
});

$(document).ready(() => {
  try {
    $('input[name$="_time"]').daterangepicker({
      autoApply: true,
      autoUpdateInput: true,
      format: 'YYYY-MM-DD hh:ss',
      timePicker: true,
      singleDatePicker: true,
      timePickerIncrement: 5,
    });
  } catch (e) {
    console.log(e);
  }
});

$(document).ready(() => {
  $('.dropdown').dropdown({
    label: {
      transition: 'horizontal flip',
      duration: 0,
      variation: false,
    },
  });
});

$(document).ready(() => {
  $('.ui.checkbox')
  .checkbox({
    onChecked() {
      const options = $('#members_dropdown > option').toArray().map(
        (obj) => obj.value
      );
      $('#members_dropdown').dropdown('set exactly', options);
    },
    onUnchecked() {
      $('#members_dropdown').dropdown('clear');
    },
  });
});
