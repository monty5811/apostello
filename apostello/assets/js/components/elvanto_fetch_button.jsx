import React, { Component } from 'react';
import post from './../ajax_post';
import biu from 'biu.js';

class ElvantoFetchButton extends Component {
  constructor() {
    super();
    this.fetchGroups = this.fetchGroups.bind(this);
  }
  fetchGroups() {
    const success = () => {
      biu('Groups are being fetched, it may take a couple of minutes', { type: 'info' });
    };
    post(
      '/api/v1/elvanto/group_fetch/',
      {},
      success
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
