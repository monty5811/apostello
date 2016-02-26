import ReactDOM from 'react-dom';
import React from 'react';
import GroupsTable from './components/groups_table';

ReactDOM.render(
  React.createElement(GroupsTable, {
    url: '/api/v1/groups/',
    pollInterval: 20000,
  }),
  document.getElementById('groups_table')
);
