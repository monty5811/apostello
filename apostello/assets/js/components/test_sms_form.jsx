import $ from 'jquery';
import React, { Component } from 'react';

class TestSmsForm extends Component {
  constructor() {
    super();
    this.sendSms = this.sendSms.bind(this);
    this.handleTo = this.handleTo.bind(this);
    this.handleBody = this.handleBody.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.state = {
      error: false,
      waiting: false,
      success: false,
      to: '',
      body: '',
    };
  }
  handleTo(event) {
    const state = this.state;
    state.to = event.target.value;
    this.setState(state);
  }
  handleBody(event) {
    const state = this.state;
    state.body = event.target.value;
    this.setState(state);
  }
  handleSubmit(event) {
    event.preventDefault();
    this.sendSms();
  }
  sendSms() {
    const that = this;
    $.ajax({
      url: '/config/send_test_sms/',
      type: 'POST',
      data: { to_: this.state.to, body_: this.state.body },
      success() {
        that.setState({
          success: true,
          error: false,
          waiting: false,
          to: '',
          body: '',
          errorMsg: '',
        });
      },
      error(r) {
        that.setState({
          success: false,
          error: true,
          errorMsg: r.responseJSON.error,
          waiting: false,
        });
      },
    });
  }
  render() {
    let formClass = 'ui form';
    let formMsg = '';
    if (this.state.waiting) {
      formClass = 'ui loading form';
    } else if (this.state.success) {
      formClass = 'ui success form';
      formMsg = (
        <div className="ui success message">
          <div className="header">SMS sending!</div>
          <p>Check your phone to confirm!</p>
        </div>
      );
    } else if (this.state.error) {
      formClass = 'ui error form';
      formMsg = (
        <div className="ui error message">
          <div className="header">Uh oh, something went wrong!</div>
          <p>Check your Twilio settings and try again.</p>

          <p>Error:</p>
          <pre>
            {this.state.errorMsg}
          </pre>
        </div>
      );
    }
    return (
      <div className="ui raised segment">
        <h3>Send Test SMS</h3>
        <form className={formClass} onSubmit={this.handleSubmit}>
          {formMsg}
          <div className="fields">
            <div className="four wide field">
              <label>Phone Number</label>
              <input
                type="email"
                value={this.state.to}
                name="sms-to"
                placeholder="+447095320967"
                onChange={this.handleTo}
              />
            </div>
            <div className="twelve wide field">
              <label>SMS Body</label>
              <input
                type="text"
                value={this.state.body}
                name="sms-body"
                placeholder="This is a test"
                onChange={this.handleBody}
              />
            </div>
          </div>

          <button
            className="ui violet button"
            type="submit"
          >
            Send
          </button>
        </form>
      </div>
    );
  }
}

export default TestSmsForm;
