const React = require('react')
const ContactRow = require('./contact_row');

module.exports = React.createClass({
    archiveContact: function (contact) {
        var that = this;
        $.ajax({
            url : '/api/v1/recipients/'+contact.pk,
            type : "POST",
            data : {'archive': true},
            success : function(json) {
              that.loadResponsesFromServer()
            },
            error : function(xhr,errmsg,err) {
                window.alert("uh, oh. That didn't work.")
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
    },
    loadResponsesFromServer: function () {
        $.ajax({
            url: this.props.url,
            dataType: 'json',
            success: function (data) {
                this.setState({data: data});
            }.bind(this),
            error: function (xhr, status, err) {
                console.error(this.props.url, status, err.toString());
            }.bind(this)
        });
    },
    getInitialState: function () {
        return {data: []};
    },
    componentDidMount: function () {
        this.loadResponsesFromServer();
        setInterval(this.loadResponsesFromServer, this.props.pollInterval);
    },
    render: function () {
        var that = this;
        var rows = this.state.data.map(function (contact, index) {
            return (<ContactRow contact={contact} key={index} archiveContact={that.archiveContact.bind(null, contact)}/>)
        });
        return (
            <table className="ui padded table">
            <thead>
            <tr>
            <th>Name</th>
            <th>Last Message</th>
            <th>Received</th>
            <th></th>
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
