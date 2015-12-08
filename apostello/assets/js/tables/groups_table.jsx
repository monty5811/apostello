var ArchiveButton = React.createClass({
    render: function () {
        return(<a className='btn btn-secondary btn-sm' onClick={this.props.archiveGroup}>Archive</a>)
    }
});
var KeywordCell = React.createClass({
    render: function () {
        if (this.props.sms.matched_link === '#') {
            return (<td><b>{this.props.sms.matched_keyword}</b></td>)
        }
        else {
            return (<td><b><a href={this.props.sms.matched_link} style={{"color": "#212121"}}>{this.props.sms.matched_keyword}</a></b></td>)
        }
    }
});
var GroupRow = React.createClass({
    render: function () {
        return (
            <tr>
                <td><a href={this.props.group.url}>{this.props.group.name}</a></td>
                <td>{this.props.group.description}</td>
                <td>{"$"+this.props.group.cost}</td>
                <td><ArchiveButton group={this.props.group} archiveGroup={this.props.archiveGroup}/></td>
            </tr>
        )
    }
});
var GroupTable = React.createClass({
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
            <div className="table-responsive">
            <table className="table table-sm table-striped" style={{'tableLayout':'fixed', 'wordWrap':'break-word'}}>
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
            </div>
        );
    }
});
