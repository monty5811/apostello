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
        var rows = this.state.data.map(function (sms, index) {
                return (<SmsOutRow sms={sms} key={index}/>)
        });
        return (
            <div className="table-responsive">
            <table className="table table-sm table-striped" style={{'tableLayout':'fixed', 'wordWrap':'break-word'}}>
            <thead>
            <tr>
            <th>To</th>
            <th>Message</th>
            <th>Sent</th>
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
