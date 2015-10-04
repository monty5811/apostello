"use strict";

var Panel = React.createClass({
    displayName: "Panel",

    render: function render() {
        var first_word = this.props.content.split(" ")[0];
        var rest_of_message = this.props.content.split(" ").splice(1).join(" ");
        return React.createElement(
            "div",
            { className: "panel", onClick: this.props.toggleCard, style: this.props.styles },
            React.createElement(
                "div",
                { className: "panel-body" },
                React.createElement(
                    "span",
                    { style: { "color": "#D3D3D3" } },
                    first_word
                ),
                " ",
                rest_of_message
            )
        );
    }
});
var Response = React.createClass({
    displayName: "Response",

    render: function render() {
        if (this.props.curating) {
            if (this.props.display_on_wall) {
                var styles = { "backgroundColor": "#ffffff" };
            } else {
                var styles = { "backgroundColor": "#616161" };
            }
            return React.createElement(
                "div",
                { className: "col-lg-6" },
                React.createElement(Panel, { toggleCard: this.props.toggleCard, styles: styles, content: this.props.content })
            );
        } else {
            if (this.props.display_on_wall) {
                if (this.props.preview) {
                    var styles = { "backgroundColor": "#ffffff" };
                } else {
                    var styles = { "backgroundColor": "#ffffff", "fontSize": "200%" };
                }
                return React.createElement(Panel, { toggleCard: this.props.toggleCard, styles: styles, content: this.props.content });
            } else {
                return null;
            }
        }
    }
});

var ResponseWall = React.createClass({
    displayName: "ResponseWall",

    toggleCard: function toggleCard(response) {
        var that = this;
        if (response.display_on_wall) {
            var tmp = 'false';
        } else {
            var tmp = 'true';
        }
        $.ajax({
            url: '/api/v1/sms/in/' + response.pk,
            type: "POST",
            data: { 'display_on_wall': tmp },
            success: function success(json) {
                that.loadResponsesFromServer();
            },
            error: function error(xhr, errmsg, err) {
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
    },
    loadResponsesFromServer: function loadResponsesFromServer() {
        $.ajax({
            url: this.props.url,
            dataType: 'json',
            success: (function (data) {
                this.setState({ data: data });
            }).bind(this),
            error: (function (xhr, status, err) {
                console.error(this.props.url, status, err.toString());
            }).bind(this)
        });
    },
    getInitialState: function getInitialState() {
        return { data: [] };
    },
    componentDidMount: function componentDidMount() {
        this.loadResponsesFromServer();
        setInterval(this.loadResponsesFromServer, this.props.pollInterval);
    },
    render: function render() {
        var that = this;
        var responseNodes = this.state.data.map(function (response, index) {
            if (!response.is_archived) {
                return React.createElement(Response, { preview: that.props.preview, curating: that.props.curating, pk: response.pk, content: response.content, key: index, toggleCard: that.toggleCard.bind(null, response), display_on_wall: response.display_on_wall });
            }
        });
        return React.createElement(
            "div",
            { className: "row" },
            responseNodes
        );
    }
});