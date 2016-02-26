import React, { Component } from 'react';
import KeywordCell from './keyword_cell';
import ReprocessButton from './reprocess_button';

class IncomingTableRow extends Component {
  render() {
    return (
      <tr style={{ backgroundColor: this.props.sms.matched_colour }}>
        <td>
          <a href={this.props.sms.sender_url} style={{ color: '#212121' }}>
            {this.props.sms.sender_name}
          </a>
        </td>
        <KeywordCell sms={this.props.sms} />
        <td>{this.props.sms.content}</td>
        <td className="collapsing">{this.props.sms.time_received}</td>
        <td className="collapsing">
          <ReprocessButton
            sms={this.props.sms}
            reprocessSms={this.props.reprocessSms}
          />
        </td>
      </tr>
    );
  }
}

export default IncomingTableRow;
