const React = require('react')

module.exports = React.createClass({
    render: function () {
            if (this.props.item.is_archived) {
                var txt = 'UnArchive';
            } else{
                var txt = 'Archive';
            };
        return(<a className='ui tiny grey button' onClick={this.props.archiveFn}>{txt}</a>)
        }
});
