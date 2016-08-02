import React from 'react';
import ArchiveButton from './archive_button';

const GroupRow = (props) => (
  <tr>
    <td><a href={props.group.url}>{props.group.name}</a></td>
    <td>{props.group.description}</td>
    <td className="collapsing">{`\$${props.group.cost}`}</td>
    <td className="collapsing">
      <ArchiveButton item={props.group} archiveFn={props.archiveGroup} />
    </td>
  </tr>
);

export default GroupRow;
