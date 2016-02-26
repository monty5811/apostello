import React, { Component } from 'react';
import ArchiveButton from './archive_button';
import DealWithButton from './deal_with_button';

class KeywordRespRow extends Component {
  render() {
    const className = this.props.sms.dealt_with ? '' : 'warning';
    return (
      <tr className={className}>
        <td>
          <a href={this.props.sms.sender_url} style={{ color: '#212121' }}>
            {this.props.sms.sender_name}
          </a>
        </td>
        <td>{this.props.sms.time_received}</td>
        <td>{this.props.sms.content}</td>
        <td>
          <DealWithButton sms={this.props.sms} dealWithSms={this.props.dealtWithSms} />
        </td>
        <td>
          <ArchiveButton item={this.props.sms} archiveFn={this.props.archiveSms} />
        </td>
      </tr>
    );
  }
}

export default KeywordRespRow;
