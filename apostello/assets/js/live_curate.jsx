import ReactDOM from 'react-dom';
import React from 'react';
import CurateTable from './components/curate_table';

ReactDOM.render(
  React.createElement(CurateTable, {
    pollInterval: 10000,
    url: '/api/v1/sms/live_wall/all/',
  }),
  document.getElementById('wall')
);
