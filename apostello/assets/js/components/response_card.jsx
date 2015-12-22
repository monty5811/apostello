const React = require('react');

var Card = React.createClass({
    render: function () {
        var first_word = this.props.content.split(" ")[0];
        var rest_of_message = this.props.content.split(" ").splice(1).join(" ");
        return (
            <div className="card" onClick={this.props.toggleCard} style={this.props.styles}>
                <div className="content">
                    <p><span style={{"color": "#D3D3D3"}}>{first_word}</span> {rest_of_message}</p>
                </div>
            </div>
        )
    }
});
module.exports = React.createClass({
    render: function() {
        if (this.props.curating || this.props.display_on_wall) {
            var styles = {};
            styles.backgroundColor = this.props.display_on_wall ? "#ffffff" : "#616161"
            styles.fontSize = !this.props.preview && !this.props.curating ? "200%" : "100%"
            return <Card toggleCard={this.props.toggleCard} styles={styles} content={this.props.content}/>
        }
        else {
            return null
        }
    }
});