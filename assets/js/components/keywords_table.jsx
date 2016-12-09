import React, { Component, PropTypes } from 'react';
import post from '../utils/ajax_post';
import LoadingComponent from './reloading_component';
import FilteringComponent from './filtering_component';
import KeywordRow from './keyword_row';

class KeywordsTable extends Component {
  constructor() {
    super();
    this.archiveKeyword = this.archiveKeyword.bind(this);
  }
  archiveKeyword(keyword) {
    post(
      `/api/v1/keywords/${keyword.pk}`,
      { archived: keyword.is_archived },
      this.props.deleteItemUpdate,
    );
  }
  render() {
    const that = this;
    const rows = this.props.data.map(
      (keyword, index) => <KeywordRow
        keyword={keyword}
        key={index}
        archiveKeyword={that.archiveKeyword}
      />,
    );
    return (
      <table className="ui striped definition table">
        <thead>
          <tr>
            <th />
            <th>Matches</th>
            <th>Description</th>
            <th>Auto Reply</th>
            <th>Status</th>
            <th />
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

KeywordsTable.propTypes = {
  data: PropTypes.array.isRequired,
  deleteItemUpdate: PropTypes.func.isRequired,
};

export default LoadingComponent(FilteringComponent(KeywordsTable));
