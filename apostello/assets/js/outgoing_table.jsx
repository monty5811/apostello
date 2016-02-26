import ReactDOM from 'react-dom';
import React from 'react';
import OutgoingTable from './components/outgoing_table';

ReactDOM.render(
  React.createElement(OutgoingTable, {
    url: '/api/v1/sms/out/',
    pollInterval: 20000,
  }),
  document.getElementById('outgoing_table')
);
