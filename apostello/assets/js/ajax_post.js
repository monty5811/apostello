import $ from 'jquery';

const post = (url, data, success) => {
  $.ajax({
    url,
    type: 'POST',
    data,
    success(respData) {
      success(respData);
    },
    error(xhr, errmsg, err) {
      console.log(`${xhr.status}: ${xhr.responseText}`);
      console.log(err);
    },
  });
};

export default post;
