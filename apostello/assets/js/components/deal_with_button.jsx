import React, { Component } from 'react';

class DealWithButton extends Component {
  constructor() {
    super();
    this.onClick = this.onClick.bind(this);
  }
  onClick() {
    this.props.dealWithSms(this.props.sms);
  }
  render() {
    if (this.props.sms.dealt_with) {
      return (
        <button className="ui tiny positive icon button" onClick={this.onClick}>
          <i className="checkmark icon" /> Dealt With
        </button>
      );
    }
    return (
      <button className="ui tiny orange icon button" onClick={this.onClick}>
        <i className="attention icon" /> Requires Action
      </button>
    );
  }
}

export default DealWithButton;
