import React, { Component } from 'react';
import post from './../ajax_post';

class ElvantoFetchButton extends Component {
  constructor() {
    super();
    this.fetchGroups = this.fetchGroups.bind(this);
  }
  fetchGroups() {
    post(
      '/api/v1/elvanto/group_fetch/',
      {},
      window.alert('Groups are being fetched, it may take a couple of minutes')
    );
  }
  render() {
    return (
      <button className="ui green fluid button" onClick={this.fetchGroups}>
        Fetch Groups
      </button>
    );
  }
}

export default ElvantoFetchButton;
