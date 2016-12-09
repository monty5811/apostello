import $ from 'jquery';
import ReactDOM from 'react-dom';
import React from 'react';
import ItemRemoveButton from '../../components/item_remove_button';
import IncomingTable from '../../components/incoming_table';
import GroupMemberSelect from '../../components/group_member_select';
import renderTable from '../../utils/render_table';
import initDateTimePickers from '../../utils/init_dt';
import dropdownOptions from '../../utils/dropdown_options';
import CommonView from '../common';

module.exports = class View extends CommonView {
  mount() {
    super.mount();

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
        is_archived: JSON.parse(buttonDiv.getAttribute('viewingarchive')),
      }),
      buttonDiv,
    );

    // are we rendering the group selector or the incoming table?
    if (document.getElementById('react_table') !== null) {
      renderTable(IncomingTable);
    }
    const tableDiv = document.getElementById('react_members');
    if (tableDiv !== null) {
      ReactDOM.render(
        React.createElement(
          GroupMemberSelect,
          {
            url: tableDiv.getAttribute('src'),
          },
        ),
        tableDiv,
      );
    }
  }
};
