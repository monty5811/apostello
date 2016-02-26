import ReactDOM from 'react-dom';
import React from 'react';
import IncomingTable from './components/incoming_table';

ReactDOM.render(
  React.createElement(IncomingTable, {
    url: '/api/v1/sms/in/',
    pollInterval: 20000,
  }),
  document.getElementById('incoming_table')
);
