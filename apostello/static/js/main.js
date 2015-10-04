function grey_keyword(sms) {
openSpan = '<span class="grey-txt">', closeSpan = '</span>';
   /* Make the sentence into an array */
   sms = sms.split(' ');
   /* Add span to the beginning of the array */
   sms.unshift( openSpan );
   /* Add  as the 3th value in the array */
   sms.splice( 2, 0, closeSpan );
   /* Turn it back into a string */
   sms = sms.join(' ');
   return sms
}
function display_on_wall(id, display_bool) {
    $.ajax({
            url : '/api/v1/sms/in/'+id,
            type : "POST",
            data : {'display_on_wall': display_bool },
            success : function(json) {
                console.log(json)
              if (json.display_on_wall){
              $('#dw'+json.pk).html("<a class='btn btn-xs btn-success' onclick='display_on_wall("+json.pk+", false)'>Showing</a>");
              }
              else{
              $('#dw'+json.pk).html("<a class='btn btn-xs btn-danger' onclick='display_on_wall("+json.pk+", true)'>Hidden</a>");
              }
            },
            error : function(xhr,errmsg,err) {
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
}
// This function gets cookie with a given name
function getCookie(name) {
    var cookieValue = null;
    if (document.cookie && document.cookie != '') {
        var cookies = document.cookie.split(';');
        for (var i = 0; i < cookies.length; i++) {
            var cookie = jQuery.trim(cookies[i]);
            // Does this cookie string begin with the name we want?
            if (cookie.substring(0, name.length + 1) == (name + '=')) {
                cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                break;
            }
        }
    }
    return cookieValue;
}
var csrftoken = getCookie('csrftoken');

/*
The functions below will create a header with csrftoken
*/

function csrfSafeMethod(method) {
    // these HTTP methods do not require CSRF protection
    return (/^(GET|HEAD|OPTIONS|TRACE)$/.test(method));
}
function sameOrigin(url) {
    // test that a given url is a same-origin URL
    // url could be relative or scheme relative or absolute
    var host = document.location.host; // host + port
    var protocol = document.location.protocol;
    var sr_origin = '//' + host;
    var origin = protocol + sr_origin;
    // Allow absolute or scheme relative URLs to same origin
    return (url == origin || url.slice(0, origin.length + 1) == origin + '/') ||
        (url == sr_origin || url.slice(0, sr_origin.length + 1) == sr_origin + '/') ||
        // or any other URL that isn't scheme relative or absolute i.e relative.
        !(/^(\/\/|http:|https:).*/.test(url));
}

$.ajaxSetup({
    beforeSend: function(xhr, settings) {
        if (!csrfSafeMethod(settings.type) && sameOrigin(settings.url)) {
            // Send the token to same-origin, relative URLs only.
            // Send the token only if the method warrants CSRF protection
            // Using the CSRFToken value acquired earlier
            xhr.setRequestHeader("X-CSRFToken", csrftoken);
        }
    }
});
