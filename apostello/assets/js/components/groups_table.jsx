const React = require('react')
const GroupRow = require('./group_row');

module.exports = React.createClass({
    archiveGroup: function (group) {
        var that = this;
        $.ajax({
            url : '/api/v1/groups/' + group.pk,
            type : "POST",
            data : { 'archive': true },
            success : function(json) {
              that.loadResponsesFromServer()
            },
            error : function(xhr,errmsg,err) {
                window.alert("uh, oh. That didn't work.")
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
    },
    loadResponsesFromServer: function () {
        $.ajax({
            url: this.props.url,
            dataType: 'json',
            success: function (data) {
                this.setState({data: data});
            }.bind(this),
            error: function (xhr, status, err) {
                console.error(this.props.url, status, err.toString());
            }.bind(this)
        });
    },
    getInitialState: function () {
        return {data: []};
    },
    componentDidMount: function () {
        this.loadResponsesFromServer();
        setInterval(this.loadResponsesFromServer, this.props.pollInterval);
    },
    render: function () {
        var that = this;
        var rows = this.state.data.map(function (group, index) {
                return (<GroupRow group={group} key={index} archiveGroup={that.archiveGroup.bind(null, group)}/>)
        });
        return (
            <table className="ui very basic striped table">
            <thead>
            <tr>
            <th>Name</th>
            <th>Description</th>
            <th>Cost</th>
            <th></th>
            </tr>
            </thead>
            <tbody className="searchable">
            {rows}
            </tbody>
            </table>
        );
    }
});
