const React = require('react')
const ResponseCard = require('./response_card')

module.exports = React.createClass({
    render: function () {
        var that = this;
        var responseNodes = this.props.responses.map(function (response, index) {
            var display_card = !response.is_archived;
            if (display_card) {
                // check if only showing some keywords
                var show_all = that.props.keyword === null;
                if (!show_all) {
                    display_card = response.matched_keyword == that.props.keyword;
                }
            }
            if (display_card) {
                return (
                    <ResponseCard
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
        var class_name = 'ui three cards';
        if (that.props.preview || !this.props.curate) {class_name = 'ui one cards'}
        return <div className={class_name}>{responseNodes}</div>
    }
});