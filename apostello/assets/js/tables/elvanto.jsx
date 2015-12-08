var ActionCell = React.createClass({
    render: function () {
        if (this.props.grp.loading){
            return(<td/>);
        }
        else {
            if (this.props.grp.sync) {
                return(<td><a className='btn btn-sm btn-primary' onClick={this.props.toggleSync}>Syncing</a></td>)
                }
            else{
                return(<td><a className='btn btn-sm btn-warning' onClick={this.props.toggleSync}>Disabled</a></td>)
                };
        }
    }
});
var GroupRow = React.createClass({
    render: function () {
        return (
            <tr>
                <td>{this.props.grp.name}</td>
                <td>{this.props.grp.last_synced}</td>
                <ActionCell grp={this.props.grp} toggleSync={this.props.toggleSync}/>
            </tr>
        )
    }
});
var ElvantoTable = React.createClass({
    toggleSync: function (grp) {
        var that = this;
        $.ajax({
            url : '/api/v1/elvanto/group/'+grp.pk,
            type : "POST",
            data : { 'sync': grp.sync },
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
        return {data: [{"group_name": "Loading...", "loading": true}]};
    },
    componentDidMount: function () {
        this.loadResponsesFromServer();
        setInterval(this.loadResponsesFromServer, this.props.pollInterval);
    },
    render: function () {
        var that = this;
        var rows = this.state.data.map(function (grp, index) {
                return (
                        <GroupRow
                        grp={grp}
                        key={index}
                        toggleSync={that.toggleSync.bind(null, grp)}
                        />)
        });
        return (
            <div table-responsive>
            <table className="table table-sm table-striped" style={{'tableLayout':'fixed', 'wordWrap':'break-word'}}>
            <thead>
            <tr>
            <th>Group</th>
            <th>Last Synced</th>
            <th>Sync?</th>
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
var ElvantoFetchButton = React.createClass({
    fetchGroups: function () {
        var that = this;
        $.ajax({
            url : '/api/v1/elvanto/group_fetch/',
            type : "POST",
            data : {},
            success : function(json) {
              window.alert("Groups are being fetched, it may take a couple of minutes")
            },
            error : function(xhr,errmsg,err) {
                window.alert("uh, oh. That didn't work.")
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
    },
    render: function () {
        var that = this;
        return (
            <button className="btn btn-success" onClick={this.fetchGroups}>Fetch Groups</button>
        );
    }
});
var ElvantoPullButton = React.createClass({
    pullGroups: function () {
        var that = this;
        $.ajax({
            url : '/api/v1/elvanto/group_pull/',
            type : "POST",
            data : {},
            success : function(json) {
              window.alert("Groups are being synced, it may take a couple of minutes")
            },
            error : function(xhr,errmsg,err) {
                window.alert("uh, oh. That didn't work.")
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
    },
    render: function () {
        var that = this;
        return (
            <button className="btn btn-info" onClick={this.pullGroups}>Pull Groups</button>
        );
    }
});