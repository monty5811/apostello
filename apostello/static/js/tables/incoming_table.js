"use strict";

var ReprocessButton = React.createClass({
    displayName: "ReprocessButton",

    render: function render() {
        if (this.props.sms.loading) {
            return React.createElement("div", null);
        } else {
            return React.createElement(
                "a",
                { className: "btn btn-default btn-xs", onClick: this.props.reprocessSms },
                "Reprocess"
            );
        }
    }
});
var SenderCell = React.createClass({
    displayName: "SenderCell",

    render: function render() {
        return React.createElement(
            "td",
            null,
            React.createElement(
                "a",
                { href: this.props.sms.sender_url, style: { "color": "#212121" } },
                this.props.sms.sender_name
            )
        );
    }
});
var KeywordCell = React.createClass({
    displayName: "KeywordCell",

    render: function render() {
        if (this.props.sms.matched_link === '#') {
            return React.createElement(
                "td",
                null,
                React.createElement(
                    "b",
                    null,
                    this.props.sms.matched_keyword
                )
            );
        } else {
            return React.createElement(
                "td",
                null,
                React.createElement(
                    "b",
                    null,
                    React.createElement(
                        "a",
                        { href: this.props.sms.matched_link, style: { "color": "#212121" } },
                        this.props.sms.matched_keyword
                    )
                )
            );
        }
    }
});
var SmsInRow = React.createClass({
    displayName: "SmsInRow",

    render: function render() {
        return React.createElement(
            "tr",
            { style: { 'backgroundColor': this.props.sms.matched_colour } },
            React.createElement(SenderCell, { sms: this.props.sms }),
            React.createElement(KeywordCell, { sms: this.props.sms }),
            React.createElement(
                "td",
                null,
                this.props.sms.content
            ),
            React.createElement(
                "td",
                null,
                this.props.sms.time_received
            ),
            React.createElement(
                "td",
                { className: "hidden-sm hidden-xs" },
                React.createElement(ReprocessButton, { sms: this.props.sms, reprocessSms: this.props.reprocessSms })
            )
        );
    }
});
var InTable = React.createClass({
    displayName: "InTable",

    reprocessSms: function reprocessSms(sms) {
        var that = this;
        $.ajax({
            url: '/api/v1/sms/in/' + sms.pk,
            type: "POST",
            data: { 'reingest': true },
            success: function success(json) {
                that.loadResponsesFromServer();
            },
            error: function error(xhr, errmsg, err) {
                window.alert("uh, oh. That didn't work.");
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
    },
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
        return { data: [{ "sender_name": "Loading...", "loading": true }] };
    },
    componentDidMount: function componentDidMount() {
        this.loadResponsesFromServer();
        setInterval(this.loadResponsesFromServer, this.props.pollInterval);
    },
    render: function render() {
        var that = this;
        var groupNodes = this.state.data.map(function (sms, index) {
            return React.createElement(SmsInRow, { sms: sms, key: index, reprocessSms: that.reprocessSms.bind(null, sms) });
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
                        "From"
                    ),
                    React.createElement(
                        "th",
                        { className: "col-sm-1" },
                        "Keyword"
                    ),
                    React.createElement(
                        "th",
                        null,
                        "Message"
                    ),
                    React.createElement(
                        "th",
                        { className: "col-sm-1" },
                        "Time"
                    ),
                    React.createElement("th", { className: "col-sm-1 hidden-sm hidden-xs" })
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