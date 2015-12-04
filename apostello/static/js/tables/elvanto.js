'use strict';

var ActionCell = React.createClass({
    displayName: 'ActionCell',

    render: function render() {
        if (this.props.grp.loading) {
            return React.createElement('td', null);
        } else {
            if (this.props.grp.sync) {
                return React.createElement(
                    'td',
                    null,
                    React.createElement(
                        'a',
                        { className: 'btn btn-xs btn-info', onClick: this.props.toggleSync },
                        'Syncing'
                    )
                );
            } else {
                return React.createElement(
                    'td',
                    null,
                    React.createElement(
                        'a',
                        { className: 'btn btn-xs btn-warning', onClick: this.props.toggleSync },
                        'Disabled'
                    )
                );
            };
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
                this.props.grp.name
            ),
            React.createElement(
                'td',
                null,
                this.props.grp.last_synced
            ),
            React.createElement(ActionCell, { grp: this.props.grp, toggleSync: this.props.toggleSync })
        );
    }
});
var ElvantoTable = React.createClass({
    displayName: 'ElvantoTable',

    toggleSync: function toggleSync(grp) {
        var that = this;
        $.ajax({
            url: '/api/v1/elvanto/group/' + grp.pk,
            type: "POST",
            data: { 'sync': grp.sync },
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
        return { data: [{ "group_name": "Loading...", "loading": true }] };
    },
    componentDidMount: function componentDidMount() {
        this.loadResponsesFromServer();
        setInterval(this.loadResponsesFromServer, this.props.pollInterval);
    },
    render: function render() {
        var that = this;
        var groupNodes = this.state.data.map(function (grp, index) {
            return React.createElement(GroupRow, {
                grp: grp,
                key: index,
                toggleSync: that.toggleSync.bind(null, grp)
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
                        { className: 'col-sm-2 col-md-6 col-lg-6' },
                        'Group'
                    ),
                    React.createElement(
                        'th',
                        { className: 'col-sm-2 col-md-5 col-lg-5' },
                        'Last Synced'
                    ),
                    React.createElement(
                        'th',
                        { className: 'col-sm-1 col-lg-2' },
                        'Sync?'
                    )
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
var ElvantoFetchButton = React.createClass({
    displayName: 'ElvantoFetchButton',

    fetchGroups: function fetchGroups() {
        var that = this;
        $.ajax({
            url: '/api/v1/elvanto/group_fetch/',
            type: "POST",
            data: {},
            success: function success(json) {
                window.alert("Groups are being fetched, it may take a mcouple of minutes");
            },
            error: function error(xhr, errmsg, err) {
                window.alert("uh, oh. That didn't work.");
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
    },
    render: function render() {
        var that = this;
        return React.createElement(
            'button',
            { className: 'btn btn-success', onClick: this.fetchGroups },
            'Fetch Groups'
        );
    }
});
var ElvantoPullButton = React.createClass({
    displayName: 'ElvantoPullButton',

    pullGroups: function pullGroups() {
        var that = this;
        $.ajax({
            url: '/api/v1/elvanto/group_pull/',
            type: "POST",
            data: {},
            success: function success(json) {
                window.alert("Groups are being synced, it may take a couple of minutes");
            },
            error: function error(xhr, errmsg, err) {
                window.alert("uh, oh. That didn't work.");
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
    },
    render: function render() {
        var that = this;
        return React.createElement(
            'button',
            { className: 'btn btn-info', onClick: this.pullGroups },
            'Pull Groups'
        );
    }
});