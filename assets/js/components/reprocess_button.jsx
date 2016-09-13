import React, { Component, PropTypes } from 'react';

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

ReprocessButton.propTypes = {
  sms: PropTypes.object.isRequired,
  reprocessSms: PropTypes.func.isRequired,
};

export default ReprocessButton;
