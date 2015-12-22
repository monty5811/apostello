const ReactDOM = require('react-dom');
const React = require('react');
const KeywordRespTable = require('./components/keyword_resp_table')

ReactDOM.render(
    React.createElement(KeywordRespTable, {
        url: _url,
        pollInterval: 20000,
        viewingArchive: _viewingArchive
    }),
    document.getElementById('incoming_keyword_table')
);