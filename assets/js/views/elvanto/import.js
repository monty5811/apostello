import ReactDOM from 'react-dom';
import React from 'react';
import ElvantoTable from '../../components/elvanto_table';
import ElvantoFetchButton from '../../components/elvanto_fetch_button';
import ElvantoPullButton from '../../components/elvanto_pull_button';
import renderTable from '../../utils/render_table';
import CommonView from '../common';

module.exports = class View extends CommonView {
  mount() {
    super.mount();

    renderTable(ElvantoTable);

    const fetchDiv = document.getElementById('elvanto_fetch_button');
    ReactDOM.render(
      React.createElement(ElvantoFetchButton, {
        url: fetchDiv.getAttribute('postUrl'),
      }),
      fetchDiv,
    );

    const pullDiv = document.getElementById('elvanto_pull_button');
    ReactDOM.render(
      React.createElement(ElvantoPullButton, {
        url: pullDiv.getAttribute('postUrl'),
      }),
      pullDiv,
    );
  }
};
