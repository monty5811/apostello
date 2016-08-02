import $ from 'jquery';
import React, { Component } from 'react';

class AdminUserForm extends Component {
  constructor() {
    super();
    this.createUser = this.createUser.bind(this);
    this.handleEmail = this.handleEmail.bind(this);
    this.handlePass1 = this.handlePass1.bind(this);
    this.handlePass2 = this.handlePass2.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.state = {
      error: false,
      waiting: false,
      success: false,
      to: '',
      body: '',
    };
  }
  handleEmail(event) {
    const state = this.state;
    state.email = event.target.value;
    this.setState(state);
  }
  handlePass1(event) {
    const state = this.state;
    state.pass1 = event.target.value;
    this.setState(state);
  }
  handlePass2(event) {
    const state = this.state;
    state.pass2 = event.target.value;
    this.setState(state);
  }
  handleSubmit(event) {
    event.preventDefault();
    this.createUser();
  }
  createUser() {
    const that = this;
    if (this.state.pass1 === this.state.pass2) {
      $.ajax({
        url: '/config/create_admin_user/',
        type: 'POST',
        data: {
          email_: this.state.email,
          pass_: this.state.pass1,
        },
        success() {
          that.setState({
            success: true,
            error: false,
            waiting: false,
            email: '',
            pass1: '',
            pass2: '',
            errorMsg: '',
          });
        },
        error(r) {
          that.setState({
            success: false,
            error: true,
            waiting: false,
            errorMsg: r.responseJSON.error,
          });
        },
      });
    } else {
      this.setState({
        error: true,
        waiting: false,
        errorMsg: 'Passwords do not match',
      });
    }
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
          <div className="header">Admin user created</div>
          <p>Refresh this page and you will be able to login</p>
        </div>
      );
    } else if (this.state.error) {
      formClass = 'ui error form';
      formMsg = (
        <div className="ui error message">
          <div className="header">Uh oh, something went wrong!</div>

          <p>Error:</p>
          <pre>
            {this.state.errorMsg}
          </pre>
        </div>
      );
    }
    return (
      <div className="ui raised segment">
        <h3>Create Admin User</h3>
        <form className={formClass} onSubmit={this.handleSubmit}>
          {formMsg}
          <div className="fields">
            <div className="eight wide field">
              <label htmlFor="admin_email">Email Address</label>
              <input
                type="email"
                value={this.state.email}
                name="email"
                placeholder="you@example.com"
                id="admin_email"
                onChange={this.handleEmail}
              />
            </div>
            <div className="four wide field">
              <label htmlFor="admin_pass1">Password</label>
              <input
                type="password"
                value={this.state.pass1}
                name="password"
                id="admin_pass1"
                onChange={this.handlePass1}
              />
            </div>
            <div className="four wide field">
              <label htmlFor="admin_pass2">Confirm Password</label>
              <input
                type="password"
                value={this.state.pass2}
                name="password"
                id="admin_pass2"
                onChange={this.handlePass2}
              />
            </div>
          </div>

          <button
            className="ui violet button"
            type="submit"
          >
            Create
          </button>
        </form>
      </div>
    );
  }
}

export default AdminUserForm;
