var serverListener;
var Card = React.createClass({
    render: function () {
        var first_word = this.props.content.split(" ")[0];
        var rest_of_message = this.props.content.split(" ").splice(1).join(" ");
        return (
            <div className={"card"} onClick={this.props.toggleCard} style={this.props.styles}>
                <div className={"card-block"}>
                    <p className={"card-text"}>
                    <span style={{"color": "#D3D3D3"}}>{first_word}</span> {rest_of_message}
                    </p>
                </div>
            </div>
        )
    }
});
var Response = React.createClass({
    render: function () {
        if (this.props.curating) {
            if (this.props.display_on_wall) {
                var styles = {
                    "backgroundColor": "#ffffff",
                    "borderColor": "#ffffff"
                };
            } else {
                var styles = {
                    "backgroundColor": "#616161",
                    "borderColor": "#616161",
                };
            }
            return (
                <div className={"col-lg-6"}>
                    <Card toggleCard={this.props.toggleCard} styles={styles} content={this.props.content}/>
                </div>
            )
        } else {
            if (this.props.display_on_wall) {
                if (this.props.preview) {
                    var styles = {
                        "backgroundColor": "#ffffff",
                        "borderColor": "#ffffff"
                    };
                } else {
                    var styles = {
                        "backgroundColor": "#ffffff",
                        "borderColor": "#ffffff",
                        "fontSize": "200%"
                    };
                }
                return (
                    <Card toggleCard={this.props.toggleCard} styles={styles} content={this.props.content}/>
                    )
            } else {
                return null
            }
        }
    }
});
var ResponseWall = React.createClass({
    render: function () {
        var that = this;
        var responseNodes = this.props.responses.map(function (response, index) {
            var display_card = !response.is_archived;
            if (display_card) {
                // check if only showing some keywords
                var show_all = typeof that.props.keyword === 'undefined';
                if (!show_all) {
                    display_card = response.matched_keyword == that.props.keyword;
                }
            }
            if (display_card) {
                return (
                    <Response
                    preview={that.props.preview}
                    curating={that.props.curating}
                    pk={response.pk}
                    content={response.content}
                    key={index}
                    toggleCard={that.props.toggleCard.bind(null, response)}
                    display_on_wall={response.display_on_wall}
                    />
                );
            }
        });
        return <div>{responseNodes}</div>
    }
});

var CurateContainer = React.createClass({
    toggleCard: function (response) {
        // disable interval
        clearInterval(serverListener)
        var that = this;
        if (response.display_on_wall) {
            var tmp = 'false';
        } else {
            var tmp = 'true';
        }
        var data = that.state.data;
        data[that.state.data.indexOf(response)].display_on_wall = !response.display_on_wall;
        this.setState({data: data});
        $.ajax({
            url: '/api/v1/sms/in/' + response.pk,
            type: "POST",
            data: {'display_on_wall': tmp},
            success: function (json) {
                // restart listener
                serverListener = setInterval(that.loadResponsesFromServer, that.props.pollInterval);
            },
            error: function (xhr, errmsg, err) {
                console.log(xhr.status + ": " + xhr.responseText);
                // restart listener
                serverListener = setInterval(that.loadResponsesFromServer, that.props.pollInterval);
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
        serverListener = setInterval(this.loadResponsesFromServer, this.props.pollInterval);
    },
    render: function () {
        if (this.props.curate) {
            return (
                <div className="row">
                  <div className="col-sm-8">
                    <h4>Available Messages</h4>
                    <ResponseWall curating={true} toggleCard={this.toggleCard} keyword={this.props.keyword} responses={this.state.data}/>
                   </div>
                  <div className="col-sm-3 col-sm-offset-1">
                    <h4>Live Preview</h4><p>(Click to remove.)</p>
                    <ResponseWall curating={false} preview={true} toggleCard={this.toggleCard} keyword={this.props.keyword} responses={this.state.data}/>
                  </div>
                </div>
        );
        } else {
            return (
                <div className="row">
                  <div className="col-sm-10">
                    <ResponseWall curating={false} preview={false} toggleCard={this.toggleCard} keyword={this.props.keyword} responses={this.state.data}/>
                   </div>
                </div>
        );
        }
    }
});
