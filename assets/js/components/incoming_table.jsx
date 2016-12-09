import React, { Component, PropTypes } from 'react';
import post from '../utils/ajax_post';
import LoadingComponent from './reloading_component';
import FilteringComponent from './filtering_component';
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
      this.props.loadfromserver,
    );
  }
  render() {
    const that = this;
    const rows = this.props.data.map(
      (sms, index) => <IncomingTableRow
        sms={sms}
        key={index}
        reprocessSms={that.reprocessSms}
      />,
    );
    return (
      <table className="ui table">
        <thead>
          <tr>
            <th>From</th>
            <th>Keyword</th>
            <th>Message</th>
            <th>Time</th>
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

IncomingTable.propTypes = {
  data: PropTypes.array.isRequired,
  loadfromserver: PropTypes.func.isRequired,
};

export default LoadingComponent(FilteringComponent(IncomingTable));
