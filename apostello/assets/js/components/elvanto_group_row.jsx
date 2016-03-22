import React from 'react';
import ActionCell from './action_cell';

const ElvantoGroupRow = (props) => (
  <tr>
    <td>{props.grp.name}</td>
    <td >{props.grp.last_synced}</td>
    <ActionCell grp={props.grp} toggleSync={props.toggleSync} />
  </tr>
);

export default ElvantoGroupRow;
