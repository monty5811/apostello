import React, { Component, PropTypes } from 'react';
import post from '../utils/ajax_post';
import LoadingComponent from './reloading_component';
import FilteringComponent from './filtering_component';
import ContactRow from './contact_row';

class ContactsTable extends Component {
  constructor() {
    super();
    this.archiveContact = this.archiveContact.bind(this);
  }
  archiveContact(contact) {
    post(
      `/api/v1/recipients/${contact.pk}`,
      { archived: contact.is_archived },
      this.props.deleteItemUpdate,
    );
  }
  render() {
    const that = this;
    const rows = this.props.data.map(
      (contact, index) => <ContactRow
        contact={contact}
        key={index}
        archiveContact={that.archiveContact}
      />,
    );
    return (
      <table className="ui padded table">
        <thead>
          <tr>
            <th>Name</th>
            <th>Last Message</th>
            <th>Received</th>
            <th />
            <th />
          </tr>
        </thead>
        <tbody className="searchable">
          {rows}
        </tbody>
      </table>
    );
  }
}

ContactsTable.propTypes = {
  data: PropTypes.array.isRequired,
  deleteItemUpdate: PropTypes.func.isRequired,
};

export default LoadingComponent(FilteringComponent(ContactsTable));
