import React from 'react';
import ArchiveButton from './archive_button';

const ContactRow = (props) => {
  const className = props.is_blocking ? 'warning' : '';
  const lastSms = props.contact.last_sms === null ?
    { content: '', time_received: '' } : props.contact.last_sms;
  const doNotReplyElem = <div className="ui horizontal red label">No reply</div>;
  const doNotReply = props.contact.do_not_reply ? doNotReplyElem : '';
  return (
    <tr className={className}>
      <td>
        <a href={props.contact.url}>{props.contact.full_name}</a> {doNotReply}
      </td>
      <td>{lastSms.content}</td>
      <td>{lastSms.time_received}</td>
      <td />
      <td>
        <ArchiveButton item={props.contact} archiveFn={props.archiveContact} />
      </td>
    </tr>
  );
};

export default ContactRow;
