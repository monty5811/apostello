const React = require('react')
const ActionCell = require('./action_cell');

module.exports = React.createClass({
    render: function() {
        return (
            <tr>
                <td>{this.props.grp.name}</td>
                <td >{this.props.grp.last_synced}</td>
                <ActionCell grp={this.props.grp} toggleSync={this.props.toggleSync}/>
            </tr>
        )
    }
});