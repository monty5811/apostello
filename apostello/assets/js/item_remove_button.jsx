const ReactDOM = require('react-dom');
const React = require('react');
const Toggle = require('./components/item_remove_button')

ReactDOM.render(
    React.createElement(Toggle, {
        url: _url,
        redirect_url: _redirect_url,
        is_archived: _is_archived
    }),
    document.getElementById('toggle_button')
);