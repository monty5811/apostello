const React = require('react');
const KeywordCell = require('./keyword_cell');
const ReprocessButton = require('./reprocess_button');

module.exports = React.createClass({
    render: function () {
        return (
            <tr style={{'backgroundColor': this.props.sms.matched_colour}}>
                <td><a href={this.props.sms.sender_url} style={{"color": "#212121"}}>{this.props.sms.sender_name}</a></td>
                <KeywordCell sms={this.props.sms}></KeywordCell>
                <td>{this.props.sms.content}</td>
                <td className="collapsing">{this.props.sms.time_received}</td>
                <td className="collapsing"><ReprocessButton sms={this.props.sms} reprocessSms={this.props.reprocessSms}/></td>
            </tr>
        )
    }
});