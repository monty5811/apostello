import React, { Component } from 'react';

class Loader extends Component {
  render() {
    return (
      <div className="ui very padded basic segment">
        <div className="ui active inverted dimmer">
          <div className="ui small text indeterminate loader">Loading</div>
        </div>
      </div>
    );
  }
}

export default Loader;
