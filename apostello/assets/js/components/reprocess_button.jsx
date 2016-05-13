import React, { Component } from 'react';

class ReprocessButton extends Component {
  constructor() {
    super();
    this.onClick = this.onClick.bind(this);
  }
  onClick() {
    this.props.reprocessSms(this.props.sms);
  }
  render() {
    if (this.props.sms.loading) {
      return <div />;
    }
    return (
      <a className="ui tiny blue button" onClick={this.onClick}>
        Reprocess
      </a>
    );
  }
}

export default ReprocessButton;
