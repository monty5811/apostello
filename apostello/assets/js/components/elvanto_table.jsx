const React = require('react')
const GroupRow = require('./elvanto_group_row');

module.exports = React.createClass({
    toggleSync: function(grp) {
        var that = this;
        $.ajax({
            url: '/api/v1/elvanto/group/' + grp.pk,
            type: "POST",
            data: {
                'sync': grp.sync
            },
            success: function(json) {
                that.loadResponsesFromServer()
            },
            error: function(xhr, errmsg, err) {
                window.alert("uh, oh. That didn't work.")
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
    },
    loadResponsesFromServer: function() {
        $.ajax({
            url: this.props.url,
            dataType: 'json',
            success: function(data) {
                this.setState({
                    data: data
                });
            }.bind(this),
            error: function(xhr, status, err) {
                console.error(this.props.url, status, err.toString());
            }.bind(this)
        });
    },
    getInitialState: function() {
        return {data: []};
    },
    componentDidMount: function() {
        this.loadResponsesFromServer();
        setInterval(this.loadResponsesFromServer, this.props.pollInterval);
    },
    render: function() {
        var that = this;
        var rows = this.state.data.map(function(grp, index) {
            return (
                <GroupRow
                        grp={grp}
                        key={index}
                        toggleSync={that.toggleSync.bind(null, grp)}
                        />)
        });
        return (
            <table className="ui striped compact definition table">
            <thead>
            <tr>
            <th></th>
            <th>Last Synced</th>
            <th>Sync?</th>
            </tr>
            </thead>
            <tbody className="searchable">
            {rows}
            </tbody>
            </table>
        );
    }
});