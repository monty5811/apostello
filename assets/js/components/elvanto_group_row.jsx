import React, { PropTypes } from 'react';
import ActionCell from './action_cell';

const ElvantoGroupRow = props => (
  <tr>
    <td>{props.grp.name}</td>
    <td >{props.grp.last_synced}</td>
    <ActionCell grp={props.grp} toggleSync={props.toggleSync} />
  </tr>
);

ElvantoGroupRow.propTypes = {
  grp: PropTypes.object.isRequired,
  toggleSync: PropTypes.func.isRequired,
};

export default ElvantoGroupRow;
