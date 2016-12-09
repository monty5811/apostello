import React, { Component, PropTypes } from 'react';
import LoadingComponent from './reloading_component';
import ResponseCard from './response_card';

class LiveWall extends Component {
  render() {
    const cards = this.props.data.map(
      (response, index) => {
        if (!response.display_on_wall) {
          return null;
        }
        return (
          <ResponseCard
            response={response}
            key={index}
          />
        );
      },
    );
    return (
      <div className="ui stackable grid fluid container">
        <div className="sixteen wide centered column">
          <div className="ui one cards">
            {cards}
          </div>
        </div>
      </div>
    );
  }
}

LiveWall.propTypes = {
  data: PropTypes.array.isRequired,
};

export default LoadingComponent(LiveWall);
