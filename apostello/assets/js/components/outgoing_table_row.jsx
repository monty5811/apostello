import React from 'react';

const OutgoingTableRow = (props) => (
  <tr>
    <td>
      <a href={props.sms.recipient_url} style={{ color: '#212121' }}>
        {props.sms.recipient}
      </a>
    </td>
    <td>{props.sms.content}</td>
    <td>{props.sms.time_sent}</td>
  </tr>
);

export default OutgoingTableRow;
