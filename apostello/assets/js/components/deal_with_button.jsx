const React = require('react');

module.exports = React.createClass({
    render: function () {
            if (this.props.sms.dealt_with) {
                return (<button className="ui tiny positive icon button" onClick={this.props.dealtWithSms}>
                    <i className="checkmark icon" /> Dealt With
                    </button>)
                }
            else{
                return (<button className="ui tiny orange icon button" onClick={this.props.dealtWithSms}>
                    <i className="attention icon" /> Requires Action
                    </button>)
                };
        }
});
