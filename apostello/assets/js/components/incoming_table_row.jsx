import React from 'react';
import KeywordCell from './keyword_cell';
import ReprocessButton from './reprocess_button';

const IncomingTableRow = (props) => (
  <tr style={{ backgroundColor: props.sms.matched_colour }}>
    <td>
      <a href={`/send/adhoc/?recipient=${props.sms.sender_pk}`}>
        <i className="violet reply link icon"></i>
      </a>
      <a href={props.sms.sender_url} style={{ color: '#212121' }}>
        {props.sms.sender_name}
      </a>
    </td>
    <KeywordCell sms={props.sms} />
    <td>{props.sms.content}</td>
    <td className="collapsing">{props.sms.time_received}</td>
    <td className="collapsing">
      <ReprocessButton
        sms={props.sms}
        reprocessSms={props.reprocessSms}
      />
    </td>
  </tr>
);

export default IncomingTableRow;
