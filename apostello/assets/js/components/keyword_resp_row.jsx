const React = require('react');
const ArchiveButton = require('./archive_button');
const DealWithButton = require('./deal_with_button');

module.exports = React.createClass({
    render: function () {
        var className = this.props.sms.dealt_with ? '' : 'warning';
        return (
            <tr className={className}>
                <td><a href={this.props.sms.sender_url} style={{"color": "#212121"}}>{this.props.sms.sender_name}</a></td>
                <td>{this.props.sms.time_received}</td>
                <td>{this.props.sms.content}</td>
                <td><DealWithButton sms={this.props.sms} dealtWithSms={this.props.dealtWithSms}/></td>
                <td><ArchiveButton item={this.props.sms} archiveFn={this.props.archiveSms}/></td>
            </tr>
        )
    }
});