import React, { Component } from 'react';

class KeywordStatus extends Component {
  render() {
    if (this.props.is_live) {
      return <div className="ui green label">Active</div>;
    }
    return <div className="ui orange label">Inactive</div>;
  }
}

export default KeywordStatus;
