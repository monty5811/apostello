import React, { Component } from 'react';

class KeywordCell extends Component {
  render() {
    if (this.props.sms.matched_link === '#') {
      return (<td><b>{this.props.sms.matched_keyword}</b></td>);
    }
    return (
      <td>
        <b>
          <a href={this.props.sms.matched_link} style={{ color: '#212121' }}>
            {this.props.sms.matched_keyword}
          </a>
        </b>
      </td>
    );
  }
}

export default KeywordCell;
