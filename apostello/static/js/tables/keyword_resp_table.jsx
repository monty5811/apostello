var ReprocessButton = React.createClass({
    render: function () {
        if (this.props.sms.loading){
        return(<div/>);
        } else {
            if (this.props.sms.is_archived) {
                var txt = 'UnArchive';
            } else{
                var txt = 'Archive';
            };
        return(<a className='btn btn-default btn-xs' onClick={this.props.archiveSms}>{txt}</a>)
        }
    }
});
var SenderCell = React.createClass({
    render: function () {
        return (
            <td>
                <a href={this.props.sms.sender_url} style={{"color": "#212121"}}>{this.props.sms.sender_name}</a>
            </td>
        )
    }
});
var ActionCell = React.createClass({
    render: function () {
        if (this.props.sms.loading){
            return(<td/>)
        }
        else {
            if (this.props.sms.dealt_with) {
                return(<td><a className='btn btn-xs btn-success' onClick={this.props.dealtWithSms}>Completed</a></td>)
                }
            else{
                return(<td><a className='btn btn-xs btn-danger' onClick={this.props.dealtWithSms}>Requires Action</a></td>)
                };
        }
    }
});
var SmsInRow = React.createClass({
    render: function () {
        return (
            <tr>
                <SenderCell sms={this.props.sms}></SenderCell>
                <td>{this.props.sms.time_received}</td>
                <td>{this.props.sms.content}</td>
                <ActionCell sms={this.props.sms} dealtWithSms={this.props.dealtWithSms}/>
                <td className="hidden-sm hidden-xs"><ReprocessButton sms={this.props.sms} archiveSms={this.props.archiveSms}/></td>
            </tr>
        )
    }
});
var KeywordRespTables = React.createClass({
    archiveSms: function (sms) {
        var that = this;
        $.ajax({
            url : '/api/v1/sms/in/'+sms.pk,
            type : "POST",
            data : { 'archive': !sms.is_archived },
            success : function(json) {
              that.loadResponsesFromServer()
            },
            error : function(xhr,errmsg,err) {
                window.alert("uh, oh. That didn't work.")
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
    },
    dealWithSms: function (sms) {
        var that = this;
        $.ajax({
            url : '/api/v1/sms/in/'+sms.pk,
            type : "POST",
            data : { 'deal_with': !sms.dealt_with },
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
        return {data: [{"sender_name": "Loading...", "loading": true}]};
    },
    componentDidMount: function () {
        this.loadResponsesFromServer();
        setInterval(this.loadResponsesFromServer, this.props.pollInterval);
    },
    render: function () {
        var that = this;
        var groupNodes = this.state.data.map(function (sms, index) {
                return (
                        <SmsInRow
                        sms={sms}
                        key={index}
                        archiveSms={that.archiveSms.bind(null, sms)}
                        dealtWithSms={that.dealWithSms.bind(null, sms)}
                        viewingArchive={that.viewingArchive}
                        />)
        });
        return (
            <table className="table table-condensed table-striped table-responsive" width="100%" style={{'tableLayout':'fixed', 'wordWrap':'break-word'}}>
            <thead>
            <tr>
            <th className="col-sm-1">From</th>
            <th className="col-sm-1">Time Received</th>
            <th className="col-sm-4">Message</th>
            <th className="col-sm-2">Requires Action?</th>
            <th className="col-sm-1 hidden-sm hidden-xs"></th>
            </tr>
            </thead>
            <tbody className="searchable">
            {groupNodes}
            </tbody>
            </table>
        );
    }
});
