import ReactDOM from 'react-dom';
import React from 'react';
import AdminUserForm from './components/admin_user_form';
import TestEmailForm from './components/test_email_form';
import TestSmsForm from './components/test_sms_form';

export function renderAdminUserForm() {
  const fetchDiv = document.getElementById('create_admin_user');
  ReactDOM.render(
    React.createElement(AdminUserForm),
    fetchDiv
  );
}

export function renderTestSmsForm() {
  const fetchDiv = document.getElementById('send_test_sms');
  ReactDOM.render(
    React.createElement(TestSmsForm),
    fetchDiv
  );
}

export function renderTestEmailForm() {
  const fetchDiv = document.getElementById('send_test_email');
  ReactDOM.render(
    React.createElement(TestEmailForm),
    fetchDiv
  );
}
