"use strict";

var Response = React.createClass({
    displayName: "Response",

    render: function render() {
        if (this.props.curating) {
            if (this.props.display_on_wall) {
                var className = "card-panel curate green waves-effect waves-light";
            } else {
                var className = "card-panel curate grey waves-effect waves-light";
            }
            return React.createElement(
                "div",
                { className: className, onClick: this.props.toggleCard },
                React.createElement("div", { dangerouslySetInnerHTML: { __html: grey_keyword(this.props.content) } })
            );
        } else {
            if (this.props.preview) {
                var className = "card-panel preview white waves-effect waves-apostello";
            } else {
                var className = "card-panel white waves-effect waves-apostello";
            }
            if (this.props.display_on_wall) {
                return React.createElement(
                    "div",
                    { className: className, onClick: this.props.toggleCard },
                    React.createElement("div", { dangerouslySetInnerHTML: { __html: grey_keyword(this.props.content) } })
                );
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
        if (this.props.curating) {} else {
            this.state.data.splice(this.state.data.indexOf(response), 1);
            this.setState({ date: this.state.data });
        }
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