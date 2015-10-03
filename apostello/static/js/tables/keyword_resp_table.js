'use strict';

var ReprocessButton = React.createClass({
    displayName: 'ReprocessButton',

    render: function render() {
        if (this.props.sms.loading) {
            return React.createElement('div', null);
        } else {
            if (this.props.sms.is_archived) {
                var txt = 'UnArchive';
            } else {
                var txt = 'Archive';
            };
            return React.createElement(
                'a',
                { className: 'btn btn-default btn-xs', onClick: this.props.archiveSms },
                txt
            );
        }
    }
});
var SenderCell = React.createClass({
    displayName: 'SenderCell',

    render: function render() {
        return React.createElement(
            'td',
            null,
            React.createElement(
                'a',
                { href: this.props.sms.sender_url, style: { "color": "#212121" } },
                this.props.sms.sender_name
            )
        );
    }
});
var ActionCell = React.createClass({
    displayName: 'ActionCell',

    render: function render() {
        if (this.props.sms.loading) {
            return React.createElement('td', null);
        } else {
            if (this.props.sms.dealt_with) {
                return React.createElement(
                    'td',
                    null,
                    React.createElement(
                        'a',
                        { className: 'btn btn-xs btn-success', onClick: this.props.dealtWithSms },
                        'Completed'
                    )
                );
            } else {
                return React.createElement(
                    'td',
                    null,
                    React.createElement(
                        'a',
                        { className: 'btn btn-xs btn-danger', onClick: this.props.dealtWithSms },
                        'Requires Action'
                    )
                );
            };
        }
    }
});
var SmsInRow = React.createClass({
    displayName: 'SmsInRow',

    render: function render() {
        return React.createElement(
            'tr',
            null,
            React.createElement(SenderCell, { sms: this.props.sms }),
            React.createElement(
                'td',
                null,
                this.props.sms.time_received
            ),
            React.createElement(
                'td',
                null,
                this.props.sms.content
            ),
            React.createElement(ActionCell, { sms: this.props.sms, dealtWithSms: this.props.dealtWithSms }),
            React.createElement(
                'td',
                { className: 'hidden-sm hidden-xs' },
                React.createElement(ReprocessButton, { sms: this.props.sms, archiveSms: this.props.archiveSms })
            )
        );
    }
});
var KeywordRespTables = React.createClass({
    displayName: 'KeywordRespTables',

    archiveSms: function archiveSms(sms) {
        var that = this;
        $.ajax({
            url: '/api/v1/sms/in/' + sms.pk,
            type: "POST",
            data: { 'archive': !sms.is_archived },
            success: function success(json) {
                that.loadResponsesFromServer();
            },
            error: function error(xhr, errmsg, err) {
                window.alert("uh, oh. That didn't work.");
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
    },
    dealWithSms: function dealWithSms(sms) {
        var that = this;
        $.ajax({
            url: '/api/v1/sms/in/' + sms.pk,
            type: "POST",
            data: { 'deal_with': !sms.dealt_with },
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
            return React.createElement(SmsInRow, {
                sms: sms,
                key: index,
                archiveSms: that.archiveSms.bind(null, sms),
                dealtWithSms: that.dealWithSms.bind(null, sms),
                viewingArchive: that.viewingArchive
            });
        });
        return React.createElement(
            'table',
            { className: 'table table-condensed table-striped table-responsive', width: '100%', style: { 'tableLayout': 'fixed', 'wordWrap': 'break-word' } },
            React.createElement(
                'thead',
                null,
                React.createElement(
                    'tr',
                    null,
                    React.createElement(
                        'th',
                        { className: 'col-sm-1' },
                        'From'
                    ),
                    React.createElement(
                        'th',
                        { className: 'col-sm-1' },
                        'Time Received'
                    ),
                    React.createElement(
                        'th',
                        { className: 'col-sm-4' },
                        'Message'
                    ),
                    React.createElement(
                        'th',
                        { className: 'col-sm-2' },
                        'Requires Action?'
                    ),
                    React.createElement('th', { className: 'col-sm-1 hidden-sm hidden-xs' })
                )
            ),
            React.createElement(
                'tbody',
                { className: 'searchable' },
                groupNodes
            )
        );
    }
});