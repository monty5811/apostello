import $ from 'jquery';
import ReactDOM from 'react-dom';
import React from 'react';
import ItemRemoveButton from '../../components/item_remove_button';
import IncomingTable from '../../components/incoming_table';
import renderTable from '../../utils/render_table';
import initDateTimePickers from '../../utils/init_dt';
import dropdownOptions from '../../utils/dropdown_options';
import CommonView from '../common';

module.exports = class View extends CommonView {
  mount() {
    super.mount();

    // create/edit group
    $('#members_dropdown').dropdown(dropdownOptions);
    // create/edit contact
    $('#groups_dropdown').dropdown(dropdownOptions);
    // create/edit keyword
    $('#linked_group_dropdown').dropdown(dropdownOptions);
    $('#owners_dropdown').dropdown(dropdownOptions);
    $('#digest_dropdown').dropdown(dropdownOptions);

    initDateTimePickers();

    const buttonDiv = document.getElementById('toggle_button');
    ReactDOM.render(
      React.createElement(ItemRemoveButton, {
        url: buttonDiv.getAttribute('postUrl'),
        redirect_url: buttonDiv.getAttribute('redirectUrl'),
        is_archived: buttonDiv.getAttribute('viewingArchive'),
      }),
      buttonDiv
    );

    renderTable(IncomingTable);
  }
};
