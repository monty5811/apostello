const ReactDOM = require('react-dom');
const React = require('react');
const OutgoingTable = require('./components/outgoing_table')

ReactDOM.render(
    React.createElement(OutgoingTable, {
        url: '/api/v1/sms/out/',
        pollInterval: 20000
    }),
    document.getElementById('outgoing_table')
);