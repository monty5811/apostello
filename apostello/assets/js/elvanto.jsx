import ReactDOM from 'react-dom';
import React from 'react';
import ElvantoTable from './components/elvanto_table';
import ElvantoFetchButton from './components/elvanto_fetch_button';
import ElvantoPullButton from './components/elvanto_pull_button';

ReactDOM.render(
  React.createElement(ElvantoFetchButton, {
    url: '/api/v1/elvanto/group_fetch/',
  }),
  document.getElementById('elvanto_fetch_button')
);
ReactDOM.render(
  React.createElement(ElvantoPullButton, {
    url: '/api/v1/elvanto/group_pull/',
  }),
  document.getElementById('elvanto_pull_button')
);
ReactDOM.render(
  React.createElement(ElvantoTable, {
    url: '/api/v1/elvanto/groups/',
    pollInterval: 50000,
  }),
  document.getElementById('elvanto_table')
);
