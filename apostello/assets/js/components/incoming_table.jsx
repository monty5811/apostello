import React, { Component } from 'react';
import post from './../ajax_post';
import { LoadingComponent } from './reloading_component';
import { FilteringComponent } from './filtering_component';
import IncomingTableRow from './incoming_table_row';

class IncomingTable extends Component {
  constructor() {
    super();
    this.reprocessSms = this.reprocessSms.bind(this);
  }
  reprocessSms(sms) {
    post(
      `/api/v1/sms/in/${sms.pk}`,
      { reingest: true },
      this.props.loadfromserver
    );
  }
  render() {
    const that = this;
    const rows = this.props.data.map(
      (sms, index) => <IncomingTableRow
        sms={sms}
        key={index}
        reprocessSms={that.reprocessSms}
      />
    );
    return (
      <table className="ui table">
        <thead>
          <tr>
            <th>From</th>
            <th>Keyword</th>
            <th>Message</th>
            <th>Time</th>
            <th></th>
          </tr>
        </thead>
        <tbody className="searchable">
          {rows}
        </tbody>
      </table>
    );
  }
}

export default LoadingComponent(FilteringComponent(IncomingTable));
