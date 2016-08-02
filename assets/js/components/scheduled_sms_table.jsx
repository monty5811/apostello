import React, { Component } from 'react';
import moment from 'moment';
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
        const t = moment(task.next_run);
        if (moment(task.next_run).isBefore()) {
          return null;
        }
        return (<ScheduledSmsTableRow
          task={task}
          sendTime={t.fromNow()}
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

export default LoadingComponent(FilteringComponent(ScheduledSmsTable));
