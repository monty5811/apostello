import React, { Component, PropTypes } from 'react';
import LoadingComponent from './reloading_component';
import ElvantoGroupRow from './elvanto_group_row';
import post from '../utils/ajax_post';

class ElvantoTable extends Component {
  constructor() {
    super();
    this.toggleSync = this.toggleSync.bind(this);
  }
  toggleSync(grp) {
    post(
      `/api/v1/elvanto/group/${grp.pk}`,
      { sync: grp.sync },
      this.props.loadfromserver,
    );
  }
  render() {
    const that = this;
    const rows = this.props.data.map(
      (grp, index) => <ElvantoGroupRow
        grp={grp}
        key={index}
        toggleSync={that.toggleSync}
      />,
    );
    return (
      <table className="ui striped compact definition table">
        <thead>
          <tr>
            <th />
            <th>Last Synced</th>
            <th>Sync?</th>
          </tr>
        </thead>
        <tbody>
          {rows}
        </tbody>
      </table>
    );
  }
}

ElvantoTable.propTypes = {
  data: PropTypes.array.isRequired,
  loadfromserver: PropTypes.func.isRequired,
};

export default LoadingComponent(ElvantoTable);
