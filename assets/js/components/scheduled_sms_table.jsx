import React, { Component, PropTypes } from 'react';
import post from '../utils/ajax_post';
import LoadingComponent from './reloading_component';
import FilteringComponent from './filtering_component';
import ScheduledSmsTableRow from './scheduled_sms_table_row';

class ScheduledSmsTable extends Component {
  constructor() {
    super();
    this.cancelSms = this.cancelSms.bind(this);
  }
  cancelSms(sms) {
    post(
      `/api/v1/queued/sms/${sms.pk}`,
      { cancel_sms: true },
      this.props.deleteItemUpdate,
    );
  }
  render() {
    const that = this;
    const rows = this.props.data.map(
      (sms, index) => {
        if (Date(sms.time_to_send) < Date()) {
          return null;
        }
        return (<ScheduledSmsTableRow
          sms={sms}
          key={index}
          cancelTask={that.cancelSms}
        />);
      },
    );
    return (
      <table className="ui table">
        <thead>
          <tr>
            <th>Queued By</th>
            <th>Recipient</th>
            <th>Group</th>
            <th>Message</th>
            <th>Scheduled Time</th>
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

ScheduledSmsTable.propTypes = {
  data: PropTypes.array.isRequired,
  deleteItemUpdate: PropTypes.func.isRequired,
};

export default LoadingComponent(FilteringComponent(ScheduledSmsTable));
