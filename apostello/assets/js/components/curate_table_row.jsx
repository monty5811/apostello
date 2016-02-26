import React, { Component } from 'react';
import CurateDisplayButton from './curate_display_button';

class CurateTableRow extends Component {
  render() {
    return (
      <tr style={{ backgroundColor: this.props.sms.matched_colour }}>
        <td>{this.props.sms.content}</td>
        <td className="collapsing">{this.props.sms.time_received}</td>
        <td className="collapsing">
          <CurateDisplayButton
            sms={this.props.sms}
            toggleSms={this.props.toggleSms}
          />
        </td>
      </tr>
    );
  }
}

export default CurateTableRow;
