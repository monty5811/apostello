import React, { Component } from 'react';

class ReprocessButton extends Component {
  constructor() {
    super();
    this._onClick = this._onClick.bind(this);
  }
  _onClick() {
    this.props.toggleSms(this.props.sms);
  }
  render() {
    let txt = 'Showing';
    let colour = 'green';
    if (!this.props.sms.display_on_wall) {
      colour = 'red';
      txt = 'Hidden';
    }
    return (
      <a className={`ui tiny ${colour} fluid button`} onClick={this._onClick}>
        {txt}
      </a>
    );
  }
}

export default ReprocessButton;
