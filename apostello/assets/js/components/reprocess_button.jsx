import React, { Component } from 'react';

class ReprocessButton extends Component {
  constructor() {
    super();
    this._onClick = this._onClick.bind(this);
  }
  _onClick() {
    this.props.reprocessSms(this.props.sms);
  }
  render() {
    if (this.props.sms.loading) {
      return <div />;
    }
    return (
      <a className="ui tiny blue button" onClick={this._onClick}>
        Reprocess
      </a>
    );
  }
}

export default ReprocessButton;
