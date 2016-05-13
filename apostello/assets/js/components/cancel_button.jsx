import React, { Component } from 'react';

class CancelButton extends Component {
  constructor() {
    super();
    this.onClick = this.onClick.bind(this);
  }
  onClick() {
    this.props.cancelFn(this.props.item);
  }
  render() {
    return (
      <a className="ui tiny grey button" onClick={this.onClick}>Cancel</a>
    );
  }
}

export default CancelButton;
