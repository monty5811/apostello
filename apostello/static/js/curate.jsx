var Response = React.createClass({
    render: function () {
        if (this.props.curating) {
            if (this.props.display_on_wall) {
                var className = "card-panel curate green waves-effect waves-light";
            } else {
                var className = "card-panel curate grey waves-effect waves-light";
            }
            return (
                <div className={className} onClick={this.props.toggleCard}>
                    <div dangerouslySetInnerHTML={{__html: grey_keyword(this.props.content)}}></div>
                </div>
            )
        } else {
            if (this.props.preview) {
                var className = "card-panel preview white waves-effect waves-apostello"
            } else {
                var className = "card-panel white waves-effect waves-apostello"
            }
            if (this.props.display_on_wall) {
                return (
                    <div className={className} onClick={this.props.toggleCard}>
                        <div dangerouslySetInnerHTML={{__html: grey_keyword(this.props.content)}}></div>
                    </div>
                )
            } else {
                return null
            }
        }
    }
});

var ResponseWall = React.createClass({
    toggleCard: function (response) {
        var that = this;
        if (this.props.curating) {
        } else {
            this.state.data.splice(this.state.data.indexOf(response), 1);
            this.setState({date: this.state.data});
        }
        if (response.display_on_wall) {
            var tmp = 'false';
        } else {
            var tmp = 'true';
        }
        $.ajax({
            url: '/api/v1/sms/in/' + response.pk,
            type: "POST",
            data: {'display_on_wall': tmp},
            success: function (json) {
                that.loadResponsesFromServer()
            },
            error: function (xhr, errmsg, err) {
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
        var responseNodes = this.state.data.map(function (response, index) {
            if (!response.is_archived) {
                return (
                    <Response preview={that.props.preview} curating={that.props.curating} pk={response.pk} content={response.content} key={index} toggleCard={that.toggleCard.bind(null, response)} display_on_wall={response.display_on_wall}>
                    </Response>
                );
            }
        });
        return (
            <div className="row">
        {responseNodes}
            </div>
        );
    }
});
