import React, { Component } from 'react';

class ArchiveButton extends Component {
  constructor() {
    super();
    this._onClick = this._onClick.bind(this);
  }
  _onClick() {
    this.props.archiveFn(this.props.item);
  }
  render() {
    let txt = 'Archive';
    if (this.props.item.is_archived) {
      txt = 'UnArchive';
    }
    return (
      <a className="ui tiny grey button" onClick={this._onClick}>
        {txt}
      </a>
    );
  }
}

export default ArchiveButton;
