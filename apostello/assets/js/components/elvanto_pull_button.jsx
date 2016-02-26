import React, { Component } from 'react';
import post from './../ajax_post';

class ElvantoPullButton extends Component {
  constructor() {
    super();
    this.pullGroups = this.pullGroups.bind(this);
  }
  pullGroups() {
    const success = () => {
      window.alert('Groups are being synced, it may take a couple of minutes');
    };
    post(
      '/api/v1/elvanto/group_pull/',
      {},
      success
    );
  }
  render() {
    return (
      <button className="ui blue fluid button" onClick={this.pullGroups}>
        Pull Groups
      </button>
    );
  }
}

export default ElvantoPullButton;
