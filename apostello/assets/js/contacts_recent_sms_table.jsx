import ReactDOM from 'react-dom';
import React from 'react';
import SmsTable from './components/incoming_table';

const tableName = document.getElementById('incoming_table').getAttribute('name');

ReactDOM.render(
  React.createElement(SmsTable, {
    url: `/api/v1/sms/in/recpient/${tableName}/`,
    pollInterval: 20000,
  }),
  document.getElementById('incoming_table')
);
