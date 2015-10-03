'use strict';

var ArchiveButton = React.createClass({
    displayName: 'ArchiveButton',

    render: function render() {
        return React.createElement(
            'a',
            { className: 'btn btn-default btn-xs', onClick: this.props.archiveContact },
            'Archive'
        );
    }
});
var ContactRow = React.createClass({
    displayName: 'ContactRow',

    render: function render() {
        if (this.props.contact.is_blocking) {
            var styles = { 'backgroundColor': '#b6b6b6' };
        } else {
            var styles = {};
        }
        return React.createElement(
            'tr',
            { style: styles },
            React.createElement(
                'td',
                null,
                React.createElement(
                    'a',
                    { href: this.props.contact.url },
                    this.props.contact.full_name
                )
            ),
            React.createElement(
                'td',
                { className: 'hidden-sm hidden-xs' },
                React.createElement(ArchiveButton, { sms: this.props.sms, archiveContact: this.props.archiveContact })
            )
        );
    }
});
var ContactsTable = React.createClass({
    displayName: 'ContactsTable',

    archiveContact: function archiveContact(contact) {
        var that = this;
        $.ajax({
            url: '/api/v1/recipients/' + contact.pk,
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
        var groupNodes = this.state.data.map(function (contact, index) {
            return React.createElement(ContactRow, { contact: contact, key: index, archiveContact: that.archiveContact.bind(null, contact) });
        });
        return React.createElement(
            'table',
            { className: 'table table-condensed table-striped table-responsive' },
            React.createElement(
                'thead',
                null,
                React.createElement(
                    'tr',
                    null,
                    React.createElement(
                        'th',
                        { className: 'col-sm-4' },
                        'Name'
                    ),
                    React.createElement('th', { className: 'col-sm-1' })
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