'use strict';

var ArchiveButton = React.createClass({
    displayName: 'ArchiveButton',

    render: function render() {
        if (this.props.keyword.loading) {
            return React.createElement('div', null);
        } else {
            if (this.props.keyword.is_archived) {
                var txt = 'UnArchive';
            } else {
                var txt = 'Archive';
            };
            return React.createElement(
                'a',
                { className: 'btn btn-default btn-xs', onClick: this.props.archiveKeyword },
                txt
            );
        }
    }
});
var StatusIndicator = React.createClass({
    displayName: 'StatusIndicator',

    render: function render() {
        if (this.props.keyword.loading) {
            return React.createElement('div', null);
        } else {
            if (this.props.keyword.is_live) {
                return React.createElement(
                    'span',
                    { className: 'label label-success' },
                    'Active'
                );
            } else {
                React.createElement(
                    'span',
                    { className: 'label label-warning' },
                    'Inactive'
                );
            };
        }
    }
});
var KeywordRow = React.createClass({
    displayName: 'KeywordRow',

    render: function render() {
        return React.createElement(
            'tr',
            null,
            React.createElement(
                'td',
                null,
                React.createElement(
                    'a',
                    { href: this.props.keyword.url },
                    this.props.keyword.keyword
                )
            ),
            React.createElement(
                'td',
                null,
                this.props.keyword.description
            ),
            React.createElement(
                'td',
                null,
                this.props.keyword.custom_response
            ),
            React.createElement(
                'td',
                null,
                React.createElement(
                    'a',
                    { href: this.props.keyword.responses_url },
                    this.props.keyword.num_replies
                )
            ),
            React.createElement(
                'td',
                null,
                React.createElement(StatusIndicator, { keyword: this.props.keyword })
            ),
            React.createElement(
                'td',
                { className: 'hidden-sm hidden-xs' },
                React.createElement(ArchiveButton, { keyword: this.props.keyword, archiveKeyword: this.props.archiveKeyword })
            )
        );
    }
});
var KeywordsTable = React.createClass({
    displayName: 'KeywordsTable',

    archiveKeyword: function archiveKeyword(keyword) {
        var that = this;
        $.ajax({
            url: '/api/v1/keywords/' + keyword.pk,
            type: "POST",
            data: { 'archive': !keyword.is_archived },
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
        var groupNodes = this.state.data.map(function (keyword, index) {
            return React.createElement(KeywordRow, {
                keyword: keyword,
                key: index,
                archiveKeyword: that.archiveKeyword.bind(null, keyword)
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
                        'Keyword'
                    ),
                    React.createElement(
                        'th',
                        { className: 'col-sm-3' },
                        'Description'
                    ),
                    React.createElement(
                        'th',
                        { className: 'col-sm-3' },
                        'Auto Reply'
                    ),
                    React.createElement(
                        'th',
                        { className: 'col-sm-1' },
                        'Matches'
                    ),
                    React.createElement(
                        'th',
                        { className: 'col-sm-1' },
                        'Status'
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