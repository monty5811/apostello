"use strict";

var RecipientCell = React.createClass({
    displayName: "RecipientCell",

    render: function render() {
        return React.createElement(
            "td",
            null,
            React.createElement(
                "a",
                { href: this.props.sms.recipient_url, style: { "color": "#212121" } },
                this.props.sms.recipient
            )
        );
    }
});
var SmsOutRow = React.createClass({
    displayName: "SmsOutRow",

    render: function render() {
        return React.createElement(
            "tr",
            null,
            React.createElement(RecipientCell, { sms: this.props.sms }),
            React.createElement(
                "td",
                null,
                this.props.sms.content
            ),
            React.createElement(
                "td",
                null,
                this.props.sms.time_sent
            )
        );
    }
});
var OutTable = React.createClass({
    displayName: "OutTable",

    loadResponsesFromServer: function loadResponsesFromServer() {
        $.ajax({
            url: this.props.url,
            dataType: 'json',
            success: (function (data) {
                this.setState({ data: data });
            }).bind(this),
            error: (function (xhr, status, err) {
                console.error(this.props.url, status, err.toString());
            }).bind(this)
        });
    },
    getInitialState: function getInitialState() {
        return { data: [{ "recipient": "Loading..." }] };
    },
    componentDidMount: function componentDidMount() {
        this.loadResponsesFromServer();
        setInterval(this.loadResponsesFromServer, this.props.pollInterval);
    },
    render: function render() {
        var that = this;
        var groupNodes = this.state.data.map(function (sms, index) {
            return React.createElement(SmsOutRow, { sms: sms, key: index });
        });
        return React.createElement(
            "table",
            { className: "table table-condensed table-striped table-responsive", width: "100%", style: { 'tableLayout': 'fixed', 'wordWrap': 'break-word' } },
            React.createElement(
                "thead",
                null,
                React.createElement(
                    "tr",
                    null,
                    React.createElement(
                        "th",
                        { className: "col-sm-1" },
                        "To"
                    ),
                    React.createElement(
                        "th",
                        null,
                        "Message"
                    ),
                    React.createElement(
                        "th",
                        { className: "col-sm-1" },
                        "Sent"
                    )
                )
            ),
            React.createElement(
                "tbody",
                { className: "searchable" },
                groupNodes
            )
        );
    }
});