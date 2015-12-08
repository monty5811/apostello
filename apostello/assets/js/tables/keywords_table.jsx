var ArchiveButton = React.createClass({
    render: function () {
        if (this.props.keyword.loading){
        return(<div/>);
        } else {
            if (this.props.keyword.is_archived) {
                var txt = 'UnArchive';
            } else{
                var txt = 'Archive';
            };
        return(<a className='btn btn-secondary btn-sm' onClick={this.props.archiveKeyword}>{txt}</a>)
        }
    }
});
var StatusIndicator = React.createClass({
    render: function () {
        if (this.props.keyword.loading){
        return(<div/>);
        } else {
            if (this.props.keyword.is_live) {
                return(<span className='label label-success'>Active</span>)
            } else{
                <span className='label label-warning'>Inactive</span>
            };
        }
    }
});
var KeywordRow = React.createClass({
    render: function () {
        return (
            <tr>
                <td><a href={this.props.keyword.url}>{this.props.keyword.keyword}</a></td>
                <td>{this.props.keyword.description}</td>
                <td>{this.props.keyword.custom_response}</td>
                <td><a href={this.props.keyword.responses_url}>{this.props.keyword.num_replies}</a></td>
                <td><StatusIndicator keyword={this.props.keyword}/></td>
                <td className="hidden-sm hidden-xs">
                    <ArchiveButton keyword={this.props.keyword} archiveKeyword={this.props.archiveKeyword}/>
                </td>
            </tr>
        )
    }
});
var KeywordsTable = React.createClass({
    archiveKeyword: function (keyword) {
        var that = this;
        $.ajax({
            url : '/api/v1/keywords/'+keyword.pk,
            type : "POST",
            data : { 'archive': !keyword.is_archived },
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
        return {data: [{"sender_name": "Loading...", "loading": true}]};
    },
    componentDidMount: function () {
        this.loadResponsesFromServer();
        setInterval(this.loadResponsesFromServer, this.props.pollInterval);
    },
    render: function () {
        var that = this;
        var rows = this.state.data.map(function (keyword, index) {
                return (
                        <KeywordRow
                        keyword={keyword}
                        key={index}
                        archiveKeyword={that.archiveKeyword.bind(null, keyword)}
                        />)
        });
        return (
            <div className="tabel-responsive">
            <table className="table table-sm table-striped" style={{'tableLayout':'fixed', 'wordWrap':'break-word'}}>
            <thead>
            <tr>
            <th>Keyword</th>
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
            </div>
        );
    }
});
