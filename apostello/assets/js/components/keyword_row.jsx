import React, { Component } from 'react';
import KeywordStatus from './keyword_status';
import ArchiveButton from './archive_button';

class KeywordRow extends Component {
  render() {
    return (
      <tr>
        <td>
          <a href={this.props.keyword.url}>{this.props.keyword.keyword}</a>
        </td>
        <td>{this.props.keyword.description}</td>
        <td>{this.props.keyword.custom_response}</td>
        <td>
          <a href={this.props.keyword.responses_url}>
            {this.props.keyword.num_replies}
          </a>
        </td>
        <td>
          <KeywordStatus is_live={this.props.keyword.is_live} />
        </td>
        <td>
          <ArchiveButton
            item={this.props.keyword}
            archiveFn={this.props.archiveKeyword}
          />
        </td>
      </tr>
    );
  }
}

export default KeywordRow;
