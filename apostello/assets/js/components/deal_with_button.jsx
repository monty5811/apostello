import React, { Component } from 'react';

class DealWithButton extends Component {
  constructor() {
    super();
    this._onClick = this._onClick.bind(this);
  }
  _onClick() {
    this.props.dealWithSms(this.props.sms);
  }
  render() {
    if (this.props.sms.dealt_with) {
      return (
        <button className="ui tiny positive icon button" onClick={this._onClick}>
          <i className="checkmark icon" /> Dealt With
        </button>
      );
    }
    return (
      <button className="ui tiny orange icon button" onClick={this._onClick}>
        <i className="attention icon" /> Requires Action
      </button>
    );
  }
}

export default DealWithButton;
