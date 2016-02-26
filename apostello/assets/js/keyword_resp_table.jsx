import ReactDOM from 'react-dom';
import React from 'react';
import KeywordRespTable from './components/keyword_resp_table';

/* global _url, _viewingArchive */

ReactDOM.render(
  React.createElement(KeywordRespTable, {
    url: _url,
    pollInterval: 20000,
    viewingArchive: _viewingArchive,
  }),
  document.getElementById('incoming_keyword_table')
);
