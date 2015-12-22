const React = require('react');
const ResponseWall = require('./response_wall');

var serverListener;

module.exports = React.createClass({
    toggleCard: function(response) {
        // disable interval
        clearInterval(serverListener)
        var that = this;
        var data = that.state.data;
        var tmp = response.display_on_wall ? 'false': 'true';
        data[that.state.data.indexOf(response)].display_on_wall = !response.display_on_wall;
        this.setState({
            data: data
        });
        $.ajax({
            url: '/api/v1/sms/in/' + response.pk,
            type: "POST",
            data: {
                'display_on_wall': tmp
            },
            success: function(json) {
                // restart listener
                serverListener = setInterval(that.loadResponsesFromServer, that.props.pollInterval);
            },
            error: function(xhr, errmsg, err) {
                console.log(xhr.status + ": " + xhr.responseText);
                // restart listener
                serverListener = setInterval(that.loadResponsesFromServer, that.props.pollInterval);
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
        serverListener = setInterval(this.loadResponsesFromServer, this.props.pollInterval);
    },
    render: function() {
        if (this.props.curate) {
            return (
                <div className="ui stackable grid container">
                  <div className="twelve wide column">
                    <h4>Available Messages</h4>
                    <ResponseWall curating={true} toggleCard={this.toggleCard} keyword={this.props.keyword} responses={this.state.data}/>
                   </div>
                  <div className="three wide column">
                    <h4>Live Preview</h4>
                    <ResponseWall curating={false} preview={true} toggleCard={this.toggleCard} keyword={this.props.keyword} responses={this.state.data}/>
                  </div>
                </div>
            );
        }
        else {
            return (
                <div className="ui stackable grid fluid container">
                  <div className="sixteen wide centered column">
                    <ResponseWall curating={false} preview={false} toggleCard={this.toggleCard} keyword={this.props.keyword} responses={this.state.data}/>
                   </div>
                </div>
            );
        }
    }
});
