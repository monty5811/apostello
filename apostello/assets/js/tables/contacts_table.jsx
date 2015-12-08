var ArchiveButton = React.createClass({
    render: function () {
        return(<a className='btn btn-secondary btn-sm' onClick={this.props.archiveContact}>Archive</a>)
    }
});
var ContactRow = React.createClass({
    render: function () {
        if (this.props.contact.is_blocking){
            var styles = {'backgroundColor': '#b6b6b6'};
        } else {
            var styles = {}
        }
        return (
            <tr style={styles}>
                <td><a href={this.props.contact.url}>{this.props.contact.full_name}</a></td>
                <td className="hidden-sm hidden-xs"><ArchiveButton sms={this.props.sms} archiveContact={this.props.archiveContact}/></td>
            </tr>
        )
    }
});
var ContactsTable = React.createClass({
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
            <div className="table-responsive">
            <table className="table table-sm table-striped">
            <thead>
            <tr>
            <th>Name</th>
            <th></th>
            </tr>
            </thead>
            <tbody className="searchable">
            {rows}
            </tbody>
            </table>
            </div>
        );
    }
});