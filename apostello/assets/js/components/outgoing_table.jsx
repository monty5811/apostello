const React = require('react');
const Loader = require('./loader');
const SmsOutRow = require('./outgoing_table_row')

module.exports = React.createClass({
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
        return {data: "loading"};
    },
    componentDidMount: function () {
        this.loadResponsesFromServer();
        setInterval(this.loadResponsesFromServer, this.props.pollInterval);
    },
    render: function () {
        if (this.state.data === 'loading') {return <Loader/>}
        var rows = this.state.data.map(function (sms, index) {
                return (<SmsOutRow sms={sms} key={index}/>)
        });
        return (
            <table className="ui table">
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
        );
    }
});
