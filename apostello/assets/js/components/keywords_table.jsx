const React = require('react');
const KeywordRow = require('./keyword_row.jsx')

module.exports = React.createClass({
    archiveKeyword: function(keyword) {
        var that = this;
        $.ajax({
            url: '/api/v1/keywords/' + keyword.pk,
            type: "POST",
            data: {
                'archive': !keyword.is_archived
            },
            success: function(json) {
                that.loadResponsesFromServer()
            },
            error: function(xhr, errmsg, err) {
                window.alert("uh, oh. That didn't work.")
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
    },
    loadResponsesFromServer: function() {
        $.ajax({
            url: this.props.url,
            dataType: 'json',
            success: function(data) {
                this.setState({
                    data: data
                });
            }.bind(this),
            error: function(xhr, status, err) {
                console.error(this.props.url, status, err.toString());
            }.bind(this)
        });
    },
    getInitialState: function() {
        return {
            data: []
        };
    },
    componentDidMount: function() {
        this.loadResponsesFromServer();
        setInterval(this.loadResponsesFromServer, this.props.pollInterval);
    },
    render: function() {
        var that = this;
        var rows = this.state.data.map(function(keyword, index) {
            return (
                <KeywordRow
                    keyword={keyword}
                    key={index}
                    archiveKeyword={that.archiveKeyword.bind(null, keyword)}
                    />)
        });
        return (
            <table className="ui striped definition table">
            <thead>
            <tr>
            <th></th>
            <th>Description</th>
            <th>Auto Reply</th>
            <th>Matches</th>
            <th>Status</th>
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
