const ReactDOM = require('react-dom');
const React = require('react');
const KeywordsTable = require('./components/keywords_table')

ReactDOM.render(
    React.createElement(KeywordsTable, {
        url: '/api/v1/keywords/',
        pollInterval: 20000
    }),
    document.getElementById('keywords_table')
);