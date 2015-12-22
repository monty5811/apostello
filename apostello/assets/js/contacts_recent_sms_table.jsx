const ReactDOM = require('react-dom');
const React = require('react');
const SmsTable = require('./components/incoming_table')

ReactDOM.render(
     React.createElement(SmsTable, {
          url: '/api/v1/sms/in/recpient/' + document.getElementById('incoming_table').getAttribute('name') + '/',
          pollInterval: 20000
     }),
     document.getElementById('incoming_table')
);