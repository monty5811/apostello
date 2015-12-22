const React = require('react');
const StatusIndicator = require('./keyword_status');
const ArchiveButton = require('./archive_button');

module.exports = React.createClass({
    render: function() {
        return (
            <tr>
                <td><a href={this.props.keyword.url}>{this.props.keyword.keyword}</a></td>
                <td>{this.props.keyword.description}</td>
                <td>{this.props.keyword.custom_response}</td>
                <td><a href={this.props.keyword.responses_url}>{this.props.keyword.num_replies}</a></td>
                <td><StatusIndicator is_live={this.props.keyword.is_live}/></td>
                <td><ArchiveButton item={this.props.keyword} archiveFn={this.props.archiveKeyword}/></td>
            </tr>
        )
    }
});