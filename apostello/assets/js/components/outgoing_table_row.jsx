const React = require('react');

module.exports = React.createClass({
    render: function () {
        return (
            <tr>
                <td><a href={this.props.sms.recipient_url} style={{"color": "#212121"}}>{this.props.sms.recipient}</a></td>
                <td>{this.props.sms.content}</td>
                <td>{this.props.sms.time_sent}</td>
            </tr>
        )
    }
});