import React, { Component } from 'react';
import ArchiveButton from './archive_button';

class GroupRow extends Component {
  render() {
    return (
      <tr>
        <td><a href={this.props.group.url}>{this.props.group.name}</a></td>
        <td>{this.props.group.description}</td>
        <td className="collapsing">{`\$${this.props.group.cost}`}</td>
        <td className="collapsing">
          <ArchiveButton item={this.props.group} archiveFn={this.props.archiveGroup} />
        </td>
      </tr>
    );
  }
}

export default GroupRow;
