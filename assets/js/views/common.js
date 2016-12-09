import $ from 'jquery';
import { csrfSafeMethod, getCookie, sameOrigin } from '../utils/django_cookies';

const MainView = class {
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
  }
};

export default MainView;
