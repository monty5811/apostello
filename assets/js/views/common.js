import $ from 'jquery';
import { csrfSafeMethod, getCookie, sameOrigin } from '../utils/django_cookies';
import dropdownOptions from '../utils/dropdown_options';

export default class MainView {
  mount() {
    // setup ajax
    $.ajaxSetup({
      beforeSend(xhr, settings) {
        if (!csrfSafeMethod(settings.type) && sameOrigin(settings.url)) {
          const csrftoken = getCookie('csrftoken');
          xhr.setRequestHeader('X-CSRFToken', csrftoken);
        }
      },
    });
    // setup menu
    $('#primary-menu').dropdown(dropdownOptions);
    $('#tools-menu').dropdown(dropdownOptions);
  }
}
