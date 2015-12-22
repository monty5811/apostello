const React = require('react')

module.exports = React.createClass({
    render: function() {
        return (
            <div className="ui very padded basic segment">
                  <div className="ui active inverted dimmer">
                    <div className="ui small text indeterminate loader">Loading</div>
                  </div>
            </div>)
    }
});