import ReactDOM from 'react-dom';
import React from 'react';
import AdminUserForm from '../../components/admin_user_form';
import TestEmailForm from '../../components/test_email_form';
import TestSmsForm from '../../components/test_sms_form';
import CommonView from '../common';

module.exports = class View extends CommonView {
  mount() {
    super.mount();

    const adminDiv = document.getElementById('create_admin_user');
    ReactDOM.render(
      React.createElement(AdminUserForm),
      adminDiv,
    );

    const smsDiv = document.getElementById('send_test_sms');
    ReactDOM.render(
      React.createElement(TestSmsForm),
      smsDiv,
    );

    const emailDiv = document.getElementById('send_test_email');
    ReactDOM.render(
      React.createElement(TestEmailForm),
      emailDiv,
    );
  }
};
