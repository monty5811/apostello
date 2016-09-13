import React, { Component, PropTypes } from 'react';
import post from '../utils/ajax_post';
import LoadingComponent from './reloading_component';
import FilteringComponent from './filtering_component';
import ScheduledSmsTableRow from './scheduled_sms_table_row';

class ScheduledSmsTable extends Component {
  constructor() {
    super();
    this.cancelTask = this.cancelTask.bind(this);
  }
  cancelTask(task) {
    post(
      `/api/v1/q/scheduled/sms/${task.pk}`,
      { cancel_task: true },
      this.props.deleteItemUpdate
    );
  }
  render() {
    const that = this;
    const rows = this.props.data.map(
      (task, index) => {
        if (Date(task.next_run) < Date()) {
          return null;
        }
        return (<ScheduledSmsTableRow
          task={task}
          sendTime={task.next_run_formatted}
          key={index}
          cancelTask={that.cancelTask}
        />);
      }
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
