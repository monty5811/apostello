import React, { Component } from 'react';
import UserProfileToggleCell from './user_profile_toggle_cell';

class UserProfileRow extends Component {
  render() {
    return (
      <tr className="center aligned">
        <td>{this.props.user.user.email}</td>
        <UserProfileToggleCell
          postUpdate={this.props.postUpdate}
          user={this.props.user}
          field={'approved'}
        />
        <UserProfileToggleCell
          postUpdate={this.props.postUpdate}
          user={this.props.user}
          field={'can_see_keywords'}
        />
        <UserProfileToggleCell
          postUpdate={this.props.postUpdate}
          user={this.props.user}
          field={'can_send_sms'}
        />
        <UserProfileToggleCell
          postUpdate={this.props.postUpdate}
          user={this.props.user}
          field={'can_see_contact_names'}
        />
        <UserProfileToggleCell
          postUpdate={this.props.postUpdate}
          user={this.props.user}
          field={'can_see_groups'}
        />
        <UserProfileToggleCell
          postUpdate={this.props.postUpdate}
          user={this.props.user}
          field={'can_see_incoming'}
        />
        <UserProfileToggleCell
          postUpdate={this.props.postUpdate}
          user={this.props.user}
          field={'can_see_outgoing'}
        />
        <UserProfileToggleCell
          postUpdate={this.props.postUpdate}
          user={this.props.user}
          field={'can_archive'}
        />
      </tr>
    );
  }
}

export default UserProfileRow;
