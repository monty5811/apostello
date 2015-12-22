const React = require('react');

module.exports =React.createClass({
    render: function () {
        if (this.props.sms.matched_link === '#') {
            return (<td><b>{this.props.sms.matched_keyword}</b></td>)
        }
        else {
            return (<td><b><a href={this.props.sms.matched_link} style={{"color": "#212121"}}>{this.props.sms.matched_keyword}</a></b></td>)

        }
    }
});