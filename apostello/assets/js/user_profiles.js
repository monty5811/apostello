import ReactDOM from 'react-dom';
import React from 'react';
import UserProfilesTable from './components/user_profiles_table';

ReactDOM.render(
  React.createElement(UserProfilesTable, {
    pollInterval: 20000,
    url: '/api/v1/users/profiles/',
  }),
  document.getElementById('table')
);
