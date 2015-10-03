var RecipientCell = React.createClass({
    render: function () {
        return (
            <td>
                <a href={this.props.sms.recipient_url} style={{"color": "#212121"}}>{this.props.sms.recipient}</a>
            </td>
        )
    }
});
var SmsOutRow = React.createClass({
    render: function () {
        return (
            <tr>
                <RecipientCell sms={this.props.sms}/>
                <td>{this.props.sms.content}</td>
                <td>{this.props.sms.time_sent}</td>
            </tr>
        )
    }
});
var OutTable = React.createClass({
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
        return {data: [{"recipient": "Loading..."}]};
    },
    componentDidMount: function () {
        this.loadResponsesFromServer();
        setInterval(this.loadResponsesFromServer, this.props.pollInterval);
    },
    render: function () {
        var that = this;
        var groupNodes = this.state.data.map(function (sms, index) {
                return (<SmsOutRow sms={sms} key={index}/>)
        });
        return (
            <table className="table table-condensed table-striped table-responsive" width="100%" style={{'tableLayout':'fixed', 'wordWrap':'break-word'}}>
            <thead>
            <tr>
            <th className="col-sm-1">To</th>
            <th>Message</th>
            <th className="col-sm-1">Sent</th>
            </tr>
            </thead>
            <tbody className="searchable">
            {groupNodes}
            </tbody>
            </table>
        );
    }
});
