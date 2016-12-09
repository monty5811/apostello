import React, { PropTypes } from 'react';
import MemberCard from './group_member_card';
import FilteringComponent from './filtering_component';

/* eslint react/no-unused-prop-types: "off" */

function compare(a, b) {
  if (a.full_name < b.full_name) {
    return -1;
  }
  if (a.full_name > b.full_name) {
    return 1;
  }
  return 0;
}

const Members = (props) => {
  const sorted = props.data.sort(compare);
  const cards = sorted.map(
    contact => <MemberCard
      key={contact.pk}
      contact={contact}
      postUpdate={props.postUpdate}
      isMember={props.isMember}
    />,
  );
  return (
    <div>
      <br />
      <div className="ui three stackable cards">
        {cards}
      </div>
    </div>
  );
};

Members.propTypes = {
  data: PropTypes.array.isRequired,
  isMember: PropTypes.bool.isRequired,
  postUpdate: PropTypes.func.isRequired,
};

export default FilteringComponent(Members);
