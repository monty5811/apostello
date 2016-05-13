import React, { Component } from 'react';

class ActionCell extends Component {
  constructor() {
    super();
    this.onClick = this.onClick.bind(this);
  }
  onClick() {
    this.props.toggleSync(this.props.grp);
  }
  render() {
    if (this.props.grp.sync) {
      return (
        <td>
          <a className="ui tiny green button" onClick={this.onClick}>
            Syncing
          </a>
        </td>
      );
    }
    return (
      <td>
        <a className="ui tiny grey button" onClick={this.onClick}>
          Disabled
        </a>
      </td>
    );
  }
}

export default ActionCell;
