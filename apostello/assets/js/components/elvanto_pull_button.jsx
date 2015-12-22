const React = require('react')

module.exports = React.createClass({
    pullGroups: function() {
        var that = this;
        $.ajax({
            url: '/api/v1/elvanto/group_pull/',
            type: "POST",
            data: {},
            success: function(json) {
                window.alert("Groups are being synced, it may take a couple of minutes")
            },
            error: function(xhr, errmsg, err) {
                window.alert("uh, oh. That didn't work.")
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
    },
    render: function() {
        var that = this;
        return (
            <button className="ui blue fluid button" onClick={this.pullGroups}>Pull Groups</button>
        );
    }
});