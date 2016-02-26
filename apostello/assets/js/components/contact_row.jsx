import React, { Component } from 'react';
import ArchiveButton from './archive_button';

class ContactRow extends Component {
  render() {
    const className = this.props.is_blocking ? 'warning' : '';
    const lastSms = this.props.contact.last_sms === null ?
      { content: '', time_received: '' } : this.props.contact.last_sms;
    return (
      <tr className={className}>
        <td>
          <a href={this.props.contact.url}>{this.props.contact.full_name}</a>
        </td>
        <td>{lastSms.content}</td>
        <td>{lastSms.time_received}</td>
        <td />
        <td>
          <ArchiveButton item={this.props.contact} archiveFn={this.props.archiveContact} />
        </td>
      </tr>
    );
  }
}

export default ContactRow;
