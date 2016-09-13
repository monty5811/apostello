import $ from 'jquery';
import biu from 'biu.js';

const post = (url, data, success, failed) => {
  $.ajax({
    url,
    type: 'POST',
    data,
    success(respData) {
      success(respData);
    },
    error() {
      biu('Something went wrong there, sorry!', { type: 'warning' });
      if (failed) {
        failed();
      }
    },
  });
};

export default post;
