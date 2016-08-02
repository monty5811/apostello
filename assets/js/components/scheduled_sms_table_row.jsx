import React from 'react';
import CancelButton from './cancel_button';

const ScheduledSmsTableRow = (props) => (
  <tr>
    <td>{props.task.queued_by}</td>
    <td>
      <a href={props.task.recipient.url}>{props.task.recipient.full_name}</a>
    </td>
    <td>
      <a href={props.task.recipient_group.url}>
        {props.task.recipient_group.name}
      </a>
    </td>
    <td>{props.task.message_body}</td>
    <td>{props.sendTime}</td>
    <td>
      <CancelButton item={props.task} cancelFn={props.cancelTask} />
    </td>
  </tr>
);

export default ScheduledSmsTableRow;
