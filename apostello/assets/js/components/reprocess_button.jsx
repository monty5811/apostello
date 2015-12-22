const React = require('react');

module.exports = React.createClass({
    render: function () {
        if (this.props.sms.loading){
        return(<div/>);
        } else {
        return(<a className='ui tiny blue button' onClick={this.props.reprocessSms}>Reprocess</a>)
        }
    }
});
