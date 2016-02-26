import React, { Component } from 'react';

class ActionCell extends Component {
  constructor() {
    super();
    this._onClick = this._onClick.bind(this);
  }
  _onClick() {
    this.props.toggleSync(this.props.grp);
  }
  render() {
    if (this.props.grp.sync) {
      return (
        <td>
          <a className="ui tiny green button" onClick={this._onClick}>
            Syncing
          </a>
        </td>
      );
    }
    return (
      <td>
        <a className="ui tiny grey button" onClick={this._onClick}>
          Disabled
        </a>
      </td>
    );
  }
}

export default ActionCell;
