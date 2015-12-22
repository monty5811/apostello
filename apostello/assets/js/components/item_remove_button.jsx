const React = require('react')

module.exports = React.createClass({
    archiveItem: function() {
        var that = this;
        $.ajax({
            url: this.props.url,
            type: "POST",
            data: {
                'archive': !this.props.is_archived
            },
            success: function(json) {
                window.location.href = that.props.redirect_url;
            },
            error: function(xhr, errmsg, err) {
                window.alert("uh, oh. That didn't work.")
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
    },
    render: function () {
            if (this.props.is_archived) {
                var txt = 'Restore';
                var className = 'ui positive button';
            } else{
                var txt = 'Remove';
                var className = 'ui negative button';
            };
        return(<div className={className} onClick={this.archiveItem}>{txt}</div>)
        }
});
