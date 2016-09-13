import React, { PropTypes } from 'react';
import KeywordStatus from './keyword_status';
import ArchiveButton from './archive_button';

const KeywordRow = props => (
  <tr>
    <td>
      <a href={props.keyword.responses_url}>{props.keyword.keyword}</a>
    </td>
    <td className="center aligned">
      <a href={props.keyword.responses_url}>
        {props.keyword.num_replies}
      </a>
    </td>
    <td>{props.keyword.description}</td>
    <td>{props.keyword.current_response}</td>
    <td>
      <KeywordStatus is_live={props.keyword.is_live} />
    </td>
    <td>
      <a href={props.keyword.url} className="ui tiny primary button">Edit</a>
    </td>
    <td>
      <ArchiveButton
        item={props.keyword}
        archiveFn={props.archiveKeyword}
      />
    </td>
  </tr>
);

KeywordRow.propTypes = {
  keyword: PropTypes.object.isRequired,
  archiveKeyword: PropTypes.func.isRequired,
};

export default KeywordRow;
