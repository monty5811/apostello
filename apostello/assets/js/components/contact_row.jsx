const React = require('react');
const ArchiveButton = require('./archive_button')

module.exports = React.createClass({
    render: function () {
        if (this.props.contact.is_blocking){
            var className = 'warning';
        } else {
            var className = ''
        };
        return (
            <tr className={className}>
                <td><a href={this.props.contact.url}>{this.props.contact.full_name}</a></td>
                <td><ArchiveButton item={this.props.contact} archiveFn={this.props.archiveContact}/></td>
            </tr>
        )
    }
});