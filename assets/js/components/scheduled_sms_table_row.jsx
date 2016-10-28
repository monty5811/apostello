import React, { PropTypes } from 'react';
import CancelButton from './cancel_button';

const GroupLink = (props) => {
  if (props.group === null) {
    return <div />;
  }
  return (
    <a href={props.group.url}>
      {props.group.name}
    </a>
  );
};

GroupLink.propTypes = {
  group: PropTypes.object.isOptional,
};

const ScheduledSmsTableRow = props => (
  <tr className={props.sms.failed ? 'negative' : ''}>
    <td>{props.sms.sent_by}</td>
    <td>
      <a href={props.sms.recipient.url}>{props.sms.recipient.full_name}</a>
    </td>
    <td>
      <GroupLink group={props.sms.recipient_group} />
    </td>
    <td>{props.sms.content}</td>
    <td>{props.sms.time_to_send_formatted}</td>
    <td>
      <CancelButton item={props.sms} cancelFn={props.cancelTask} />
    </td>
  </tr>
);

ScheduledSmsTableRow.propTypes = {
  sms: PropTypes.object.isRequired,
  cancelTask: PropTypes.func.isRequired,
};

export default ScheduledSmsTableRow;
