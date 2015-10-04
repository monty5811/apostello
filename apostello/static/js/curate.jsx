var Panel = React.createClass({
    render: function () {
        var first_word = this.props.content.split(" ")[0];
        var rest_of_message = this.props.content.split(" ").splice(1).join(" ")
        return (
            <div className={"panel"} onClick={this.props.toggleCard} style={this.props.styles}>
                <div className={"panel-body"}>
                    <span style={{"color": "#D3D3D3"}}>{first_word}</span> {rest_of_message}
                </div>
            </div>
        )
    }
});
var Response = React.createClass({
    render: function () {
        if (this.props.curating) {
            if (this.props.display_on_wall) {
                var styles = {"backgroundColor": "#ffffff"};
            } else {
                var styles = {"backgroundColor": "#616161"};
            }
            return (
                <div className={"col-lg-6"}>
                    <Panel toggleCard={this.props.toggleCard} styles={styles} content={this.props.content}/>
                </div>
            )
        } else {
            if (this.props.display_on_wall) {
                if (this.props.preview) {
                    var styles = {"backgroundColor": "#ffffff"};
                } else {
                    var styles = {"backgroundColor": "#ffffff", "fontSize": "200%"};
                }
                return (
                    <Panel toggleCard={this.props.toggleCard} styles={styles} content={this.props.content}/>
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
