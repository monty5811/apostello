const React = require('react');
const Loader = require('./loader');
const SmsInRow = require('./incoming_table_row');

module.exports = React.createClass({
    reprocessSms: function (sms) {
        var that = this;
        $.ajax({
            url : '/api/v1/sms/in/'+sms.pk,
            type : "POST",
            data : { 'reingest': true },
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
        return {data: 'loading'};
    },
    componentDidMount: function () {
        this.loadResponsesFromServer();
        setInterval(this.loadResponsesFromServer, this.props.pollInterval);
    },
    render: function () {
        var that = this;
        if (this.state.data === 'loading') {return <Loader/>}
        var rows = this.state.data.map(function (sms, index) {
                return (<SmsInRow sms={sms} key={index} reprocessSms={that.reprocessSms.bind(null, sms)}/>)
        });
        return (
            <table className="ui table">
            <thead>
            <tr>
            <th>From</th>
            <th>Keyword</th>
            <th>Message</th>
            <th>Time</th>
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
