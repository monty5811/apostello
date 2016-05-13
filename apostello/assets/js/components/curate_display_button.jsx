import React, { Component } from 'react';

class ReprocessButton extends Component {
  constructor() {
    super();
    this.onClick = this.onClick.bind(this);
  }
  onClick() {
    this.props.toggleSms(this.props.sms);
  }
  render() {
    let txt = 'Showing';
    let colour = 'green';
    if (!this.props.sms.displayon_wall) {
      colour = 'red';
      txt = 'Hidden';
    }
    return (
      <a className={`ui tiny ${colour} fluid button`} onClick={this.onClick}>
        {txt}
      </a>
    );
  }
}

export default ReprocessButton;
