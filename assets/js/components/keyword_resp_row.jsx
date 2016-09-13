import React, { PropTypes } from 'react';
import ArchiveButton from './archive_button';
import DealWithButton from './deal_with_button';

const KeywordRespRow = (props) => {
  const className = props.sms.dealt_with ? '' : 'warning';
  return (
    <tr className={className}>
      <td>
        <a href={props.sms.sender_url} style={{ color: '#212121' }}>
          {props.sms.sender_name}
        </a>
      </td>
      <td>{props.sms.time_received}</td>
      <td>{props.sms.content}</td>
      <td>
        <DealWithButton sms={props.sms} dealWithSms={props.dealWithSms} />
      </td>
      <td>
        <ArchiveButton item={props.sms} archiveFn={props.archiveSms} />
      </td>
    </tr>
  );
};

KeywordRespRow.propTypes = {
  sms: PropTypes.object.isRequired,
  archiveSms: PropTypes.func.isRequired,
  dealWithSms: PropTypes.func.isRequired,
};

export default KeywordRespRow;
