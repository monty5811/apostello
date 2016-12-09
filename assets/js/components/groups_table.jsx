import React, { Component, PropTypes } from 'react';
import post from '../utils/ajax_post';
import LoadingComponent from './reloading_component';
import FilteringComponent from './filtering_component';
import GroupRow from './group_row';

class GroupsTable extends Component {
  constructor() {
    super();
    this.archiveGroup = this.archiveGroup.bind(this);
  }
  archiveGroup(group) {
    post(
      `/api/v1/groups/${group.pk}`,
      { archived: group.is_archived },
      this.props.deleteItemUpdate,
    );
  }
  render() {
    const that = this;
    const rows = this.props.data.map(
      (group, index) => <GroupRow
        group={group}
        key={index}
        archiveGroup={that.archiveGroup}
      />,
    );
    return (
      <table className="ui very basic striped table">
        <thead>
          <tr>
            <th>Name</th>
            <th>Description</th>
            <th>Cost</th>
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

GroupsTable.propTypes = {
  data: PropTypes.array.isRequired,
  deleteItemUpdate: PropTypes.func.isRequired,
};

export default LoadingComponent(FilteringComponent(GroupsTable));
