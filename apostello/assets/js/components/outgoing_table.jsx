import React, { Component } from 'react';
import { LoadingComponent } from './reloading_component';
import { FilteringComponent } from './filtering_component';
import OutgoingTableRow from './outgoing_table_row';

class OutgoingTable extends Component {
  render() {
    const rows = this.props.data.map(
      (sms, index) => <OutgoingTableRow
        sms={sms}
        key={index}
      />
    );
    return (
      <table className="ui table">
        <thead>
          <tr>
            <th>To</th>
            <th>Message</th>
            <th>Sent</th>
          </tr>
        </thead>
        <tbody className="searchable">
          {rows}
        </tbody>
      </table>
    );
  }
}

export default LoadingComponent(FilteringComponent(OutgoingTable));
