import React, { Component } from 'react';

class CancelButton extends Component {
  constructor() {
    super();
    this._onClick = this._onClick.bind(this);
  }
  _onClick() {
    this.props.cancelFn(this.props.item);
  }
  render() {
    return (
      <a className="ui tiny grey button" onClick={this._onClick}>Cancel</a>
    );
  }
}

export default CancelButton;
