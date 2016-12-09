import biu from 'biu.js';
import React, { Component } from 'react';
import post from '../utils/ajax_post';

class ElvantoFetchButton extends Component {
  fetchGroups() {
    const success = () => {
      biu(
        'Groups are being fetched, it may take a couple of minutes',
        { type: 'info', autoHide: false },
      );
    };
    post(
      '/api/v1/elvanto/group_fetch/',
      {},
      success,
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
