import React, { Component } from 'react';
import ActionCell from './action_cell';

class ElvantoGroupRow extends Component {
  render() {
    return (
      <tr>
        <td>{this.props.grp.name}</td>
        <td >{this.props.grp.last_synced}</td>
        <ActionCell grp={this.props.grp} toggleSync={this.props.toggleSync} />
      </tr>
    );
  }
}

export default ElvantoGroupRow;
