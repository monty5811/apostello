import ReactDOM from 'react-dom';
import React from 'react';
import LiveWall from './components/live_wall';

ReactDOM.render(
  React.createElement(LiveWall, {
    pollInterval: 2000,
    url: '/api/v1/sms/live_wall/all/',
  }),
  document.getElementById('wall')
);
