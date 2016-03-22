import React from 'react';

const KeywordCell = (props) => {
  if (props.sms.matched_link === '#') {
    return (<td><b>{props.sms.matched_keyword}</b></td>);
  }
  return (
      <td>
        <b>
          <a href={props.sms.matched_link} style={{ color: '#212121' }}>
            {props.sms.matched_keyword}
          </a>
        </b>
      </td>
      );
};

export default KeywordCell;
