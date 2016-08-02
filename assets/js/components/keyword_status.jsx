import React from 'react';

const KeywordStatus = (props) => {
  if (props.is_live) {
    return <div className="ui green label">Active</div>;
  }
  return <div className="ui orange label">Inactive</div>;
};

export default KeywordStatus;
