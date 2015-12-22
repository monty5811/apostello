const React = require('react')

module.exports = React.createClass({
    fetchGroups: function() {
        var that = this;
        $.ajax({
            url: '/api/v1/elvanto/group_fetch/',
            type: "POST",
            data: {},
            success: function(json) {
                window.alert("Groups are being fetched, it may take a couple of minutes")
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
            <button className="ui green fluid button" onClick={this.fetchGroups}>Fetch Groups</button>
        );
    }
});