const React = require('react');
const ArchiveButton = require('./archive_button')

module.exports = React.createClass({
    render: function () {
        const className = this.props.is_blocking ? 'warning' : '';
        const last_sms = this.props.contact.last_sms === null ? {content: '', time_received: ''} : this.props.contact.last_sms;
        return (
            <tr className={className}>
                <td><a href={this.props.contact.url}>{this.props.contact.full_name}</a></td>
                <td>{last_sms.content}</td>
                <td>{last_sms.time_received}</td>
                <td/>
                <td><ArchiveButton item={this.props.contact} archiveFn={this.props.archiveContact}/></td>
            </tr>
        )
    }
});
