import biu from 'biu.js';
import React, { Component } from 'react';
import post from '../utils/ajax_post';

class ElvantoPullButton extends Component {
  pullGroups() {
    const success = () => {
      biu(
        'Groups are being synced, it may take a couple of minutes',
        { type: 'info', autoHide: false },
      );
    };
    post(
      '/api/v1/elvanto/group_pull/',
      {},
      success,
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
