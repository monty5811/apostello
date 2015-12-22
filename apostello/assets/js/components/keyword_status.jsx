const React = require('react');

module.exports = React.createClass({
    render: function() {
        if (this.props.is_live) {
            return <div className='ui green label'>Active</div>
        }
        else {
            return <div className='ui orange label'>Inactive</div>
        };
    }
});