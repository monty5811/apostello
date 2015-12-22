const React = require('react')
const ArchiveButton = require('./archive_button');

module.exports = React.createClass({
    render: function () {
        return (
            <tr>
                <td><a href={this.props.group.url}>{this.props.group.name}</a></td>
                <td>{this.props.group.description}</td>
                <td className="collapsing">{"$"+this.props.group.cost}</td>
                <td className="collapsing"><ArchiveButton item={this.props.group} archiveFn={this.props.archiveGroup}/></td>
            </tr>
        )
    }
});