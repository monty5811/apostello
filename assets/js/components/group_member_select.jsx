import React, { Component, PropTypes } from 'react';
import $ from 'jquery';
import biu from 'biu.js';
import Loader from './loader';
import post from '../utils/ajax_post';
import Members from './group_members';

class GroupMemberSelect extends Component {
  constructor() {
    super();
    this.postUpdate = this.postUpdate.bind(this);
    this.loadFromServer = this.loadFromServer.bind(this);
    this.state = null;
  }
  componentDidMount() {
    this.loadFromServer();
  }
  postUpdate(payload) {
    // remove item from state before post
    const state = this.state;
    const membersKey = payload.member ? 'members' : 'nonmembers';
    const changedContact = state[membersKey].get(payload.contactPk);
    state[membersKey].delete(payload.contactPk);
    this.setState(state);
    // post to server
    post(
      this.props.url,
      payload,
      () => {
        biu('Saved!', { type: 'success' });
        this.loadFromServer();
      },
      () => {
        // return the state to prev value on failed request
        state[membersKey].set(payload.contactPk, changedContact);
        this.setState(state);
      },
    );
  }
  loadFromServer() {
    const that = this;
    $.ajax({
      url: this.props.url,
      dataType: 'json',
      success(data) {
        // update state
        const members = new Map();
        const nonmembers = new Map();
        data.members.map(x => members.set(x.pk, x));
        data.nonmembers.map(x => nonmembers.set(x.pk, x));
        that.setState(
          {
            members,
            nonmembers,
          },
        );
      },
      error(xhr, errmsg) {
        biu(errmsg, { type: 'warning' });
      },
    });
  }
  render() {
    if (this.state === null) {
      return <Loader />;
    }
    return (
      <div>
        <h3>Group Members</h3>
        <p>Click a person to toggle their membership.</p>
        <div className="ui two column celled grid">
          <div className="ui column">
            <h4>Non-Members</h4>
            <Members
              data={Array.from(this.state.nonmembers.values())}
              postUpdate={this.postUpdate}
              isMember={false}
            />
          </div>
          <div className="ui column">
            <h4>Members</h4>
            <Members
              data={Array.from(this.state.members.values())}
              postUpdate={this.postUpdate}
              isMember
            />
          </div>
        </div>
      </div>
    );
  }
}

GroupMemberSelect.propTypes = {
  url: PropTypes.string.isRequired,
};

export default GroupMemberSelect;
