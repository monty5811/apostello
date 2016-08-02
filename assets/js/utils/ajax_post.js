import $ from 'jquery';
import biu from 'biu.js';

const post = (url, data, success) => {
  $.ajax({
    url,
    type: 'POST',
    data,
    success(respData) {
      success(respData);
    },
    error(xhr, errmsg, err) {
      biu(err, { type: 'warning' });
      console.log(`${xhr.status}: ${xhr.responseText}`);
      console.log(err);
    },
  });
};

export default post;
