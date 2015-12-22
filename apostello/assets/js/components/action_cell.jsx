const React = require('react')

module.exports = React.createClass({
    render: function() {
        if (this.props.grp.sync) {
            return (<td><a className='ui tiny green button' onClick={this.props.toggleSync}>Syncing</a></td>)
        }
        else {
            return (<td><a className='ui tiny grey button' onClick={this.props.toggleSync}>Disabled</a></td>)
        };
    }
});