import ReactDOM from 'react-dom';
import React from 'react';

function renderTable(TableClass) {
  const tableDiv = document.getElementById('react_table');
  const toggleDiv = document.getElementById('toggle_button');
  const viewingArchive = toggleDiv === null ? {} : toggleDiv.getAttribute('viewingArchive');
  ReactDOM.render(
    React.createElement(TableClass, {
      url: tableDiv.getAttribute('src'),
      pollInterval: tableDiv.getAttribute('pollInterval'),
      viewingArchive,
    }),
    tableDiv,
  );
}

export default renderTable;
