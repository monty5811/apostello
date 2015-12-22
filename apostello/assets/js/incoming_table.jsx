const ReactDOM = require('react-dom');
const React = require('react');
const IncomingTable = require('./components/incoming_table')

ReactDOM.render(
    React.createElement(IncomingTable, {
        url: '/api/v1/sms/in/',
        pollInterval: 20000
    }),
    document.getElementById('incoming_table')
);