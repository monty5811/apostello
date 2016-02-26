import ReactDOM from 'react-dom';
import React from 'react';
import ContactsTable from './components/contacts_table';

ReactDOM.render(
  React.createElement(ContactsTable, {
    url: '/api/v1/recipients/',
    pollInterval: 20000,
  }),
  document.getElementById('contacts_table')
);
