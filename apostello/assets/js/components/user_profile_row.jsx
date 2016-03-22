import React from 'react';
import UserProfileToggleCell from './user_profile_toggle_cell';

const UserProfileRow = (props) => (
  <tr className="center aligned">
    <td>{props.user.user.email}</td>
    <UserProfileToggleCell
      postUpdate={props.postUpdate}
      user={props.user}
      field={'approved'}
    />
    <UserProfileToggleCell
      postUpdate={props.postUpdate}
      user={props.user}
      field={'can_see_keywords'}
    />
    <UserProfileToggleCell
      postUpdate={props.postUpdate}
      user={props.user}
      field={'can_send_sms'}
    />
    <UserProfileToggleCell
      postUpdate={props.postUpdate}
      user={props.user}
      field={'can_see_contact_names'}
    />
    <UserProfileToggleCell
      postUpdate={props.postUpdate}
      user={props.user}
      field={'can_see_groups'}
    />
    <UserProfileToggleCell
      postUpdate={props.postUpdate}
      user={props.user}
      field={'can_see_incoming'}
    />
    <UserProfileToggleCell
      postUpdate={props.postUpdate}
      user={props.user}
      field={'can_see_outgoing'}
    />
    <UserProfileToggleCell
      postUpdate={props.postUpdate}
      user={props.user}
      field={'can_archive'}
    />
  </tr>
);

export default UserProfileRow;
