const ReactDOM = require('react-dom');
const React = require('react');
const GroupsTable = require('./components/groups_table')

ReactDOM.render(
    React.createElement(GroupsTable, {
        url: '/api/v1/groups/',
        pollInterval: 20000
    }),
    document.getElementById('groups_table')
);