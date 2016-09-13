import React, { PropTypes } from 'react';

const KeywordStatus = (props) => {
  if (props.is_live) {
    return <div className="ui green label">Active</div>;
  }
  return <div className="ui orange label">Inactive</div>;
};

KeywordStatus.propTypes = {
  is_live: PropTypes.bool.isRequired,
};

export default KeywordStatus;
