'use strict';

var ArchiveButton = React.createClass({
    displayName: 'ArchiveButton',

    render: function render() {
        return React.createElement(
            'a',
            { className: 'btn btn-default btn-xs', onClick: this.props.archiveGroup },
            'Archive'
        );
    }
});
var KeywordCell = React.createClass({
    displayName: 'KeywordCell',

    render: function render() {
        if (this.props.sms.matched_link === '#') {
            return React.createElement(
                'td',
                null,
                React.createElement(
                    'b',
                    null,
                    this.props.sms.matched_keyword
                )
            );
        } else {
            return React.createElement(
                'td',
                null,
                React.createElement(
                    'b',
                    null,
                    React.createElement(
                        'a',
                        { href: this.props.sms.matched_link, style: { "color": "#212121" } },
                        this.props.sms.matched_keyword
                    )
                )
            );
        }
    }
});
var GroupRow = React.createClass({
    displayName: 'GroupRow',

    render: function render() {
        return React.createElement(
            'tr',
            null,
            React.createElement(
                'td',
                null,
                React.createElement(
                    'a',
                    { href: this.props.group.url },
                    this.props.group.name
                )
            ),
            React.createElement(
                'td',
                null,
                this.props.group.description
            ),
            React.createElement(
                'td',
                null,
                "$" + this.props.group.cost
            ),
            React.createElement(
                'td',
                { className: 'hidden-sm hidden-xs' },
                React.createElement(ArchiveButton, { group: this.props.group, archiveGroup: this.props.archiveGroup })
            )
        );
    }
});
var GroupTable = React.createClass({
    displayName: 'GroupTable',

    archiveGroup: function archiveGroup(group) {
        var that = this;
        $.ajax({
            url: '/api/v1/groups/' + group.pk,
            type: "POST",
            data: { 'archive': true },
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
        return { data: [] };
    },
    componentDidMount: function componentDidMount() {
        this.loadResponsesFromServer();
        setInterval(this.loadResponsesFromServer, this.props.pollInterval);
    },
    render: function render() {
        var that = this;
        var groupNodes = this.state.data.map(function (group, index) {
            return React.createElement(GroupRow, { group: group, key: index, archiveGroup: that.archiveGroup.bind(null, group) });
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
                        'Name'
                    ),
                    React.createElement(
                        'th',
                        { className: 'col-sm-2' },
                        'Description'
                    ),
                    React.createElement(
                        'th',
                        { className: 'col-xs-1' },
                        'Cost'
                    ),
                    React.createElement('th', { className: 'col-xs-1 hidden-sm hidden-xs' })
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