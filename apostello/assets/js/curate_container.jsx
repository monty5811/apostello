const ReactDOM = require('react-dom');
const React = require('react');
const CurateContainer = require('./components/curate_container')

ReactDOM.render(
     React.createElement(CurateContainer,
     {curate: wall_curate, keyword: wall_keyword, pollInterval: wall_poll_interval, url: wall_url}),
     document.getElementById('wall')
);