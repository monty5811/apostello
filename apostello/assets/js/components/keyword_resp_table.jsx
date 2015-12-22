const React = require('react');
const SmsInRow = require('./keyword_resp_row')

module.exports = React.createClass({
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
        var rows = this.state.data.map(function (sms, index) {
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
            <table className="ui table">
            <thead>
            <tr>
            <th>From</th>
            <th>Time Received</th>
            <th>Message</th>
            <th>Requires Action?</th>
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
