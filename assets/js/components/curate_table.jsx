import React, { Component, PropTypes } from 'react';
import post from '../utils/ajax_post';
import LoadingComponent from './reloading_component';
import FilteringComponent from './filtering_component';
import CurateTableRow from './curate_table_row';

class CurateTable extends Component {
  constructor() {
    super();
    this.toggleSms = this.toggleSms.bind(this);
  }
  toggleSms(sms) {
    post(
      `/api/v1/sms/in/${sms.pk}`,
      { display_on_wall: sms.display_on_wall },
      this.props.loadfromserver,
    );
  }
  render() {
    const that = this;
    const rows = this.props.data.map(
      (sms, index) => <CurateTableRow
        sms={sms}
        key={index}
        toggleSms={that.toggleSms}
      />,
    );
    return (
      <table className="ui table">
        <thead>
          <tr>
            <th>Message</th>
            <th>Time</th>
            <th>Display?</th>
          </tr>
        </thead>
        <tbody className="searchable">
          {rows}
        </tbody>
      </table>
    );
  }
}

CurateTable.propTypes = {
  data: PropTypes.array.isRequired,
  loadfromserver: PropTypes.func.isRequired,
};

export default LoadingComponent(FilteringComponent(CurateTable));
