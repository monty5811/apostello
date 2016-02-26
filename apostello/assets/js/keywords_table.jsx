import ReactDOM from 'react-dom';
import React from 'react';
import KeywordsTable from './components/keywords_table';

ReactDOM.render(
  React.createElement(KeywordsTable, {
    url: '/api/v1/keywords/',
    pollInterval: 20000,
  }),
  document.getElementById('keywords_table')
);
