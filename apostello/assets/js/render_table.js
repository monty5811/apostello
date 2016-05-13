import ReactDOM from 'react-dom';
import React from 'react';
import ContactsTable from './components/contacts_table';
import CurateTable from './components/curate_table';
import ElvantoTable from './components/elvanto_table';
import GroupsTable from './components/groups_table';
import IncomingTable from './components/incoming_table';
import KeywordRespTable from './components/keyword_resp_table';
import KeywordsTable from './components/keywords_table';
import LiveWall from './components/live_wall';
import OutgoingTable from './components/outgoing_table';
import UserProfilesTable from './components/user_profiles_table';
import ScheduledSmsTable from './components/scheduled_sms_table';

/* global _url */

function renderTable() {
  // handle urls with pks:
  let path = _url.replace(/\d+\/$/, '');
  path = path.replace(/archive\/$/, '');

  const toggleDiv = document.getElementById('toggle_button');
  const viewingArchive = toggleDiv === null ? {} : toggleDiv.getAttribute('viewingArchive');

  const tables = {
    '/elvanto/import/': ElvantoTable,
    '/group/all/': GroupsTable,
    '/incoming/': IncomingTable,
    '/incoming/curate_wall/': CurateTable,
    '/incoming/wall/': LiveWall,
    '/keyword/all/': KeywordsTable,
    '/keyword/responses/': KeywordRespTable,
    '/outgoing/': OutgoingTable,
    '/recipient/all/': ContactsTable,
    '/recipient/edit/': IncomingTable,
    '/users/profiles/': UserProfilesTable,
    '/scheduled/sms/': ScheduledSmsTable,
  };

  const tableDiv = document.getElementById('react_table');
  ReactDOM.render(
    React.createElement(tables[path], {
      url: tableDiv.getAttribute('src'),
      pollInterval: tableDiv.getAttribute('pollInterval'),
      viewingArchive,
    }),
    tableDiv
  );
}

export { renderTable };
