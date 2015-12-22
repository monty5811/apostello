const ReactDOM = require('react-dom');
const React = require('react');
const ContactsTable = require('./components/contacts_table')

ReactDOM.render(
    React.createElement(ContactsTable, {
        url: '/api/v1/recipients/',
        pollInterval: 20000
    }),
    document.getElementById('contacts_table')
);