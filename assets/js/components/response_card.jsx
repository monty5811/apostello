import React, { Component } from 'react';

class ResponseCard extends Component {
  constructor() {
    super();
    this.onClick = this.onClick.bind(this);
  }
  onClick() {
    this.props.toggleCard(this.props.response);
  }
  render() {
    const resp = this.props.response;
    const firstWord = resp.content.split(' ')[0];
    const restOfMessage = resp.content.split(' ').splice(1).join(' ');
    const styles = {
      backgroundColor: resp.displayon_wall ? '#ffffff' : '#616161',
      fontSize: !this.props.preview && !this.props.curating ? '200%' : '100%',
    };
    return (
      <div className="card" onClick={this.onClick} style={styles}>
        <div className="content">
          <p><span style={{ color: '#D3D3D3' }}>{firstWord}</span> {restOfMessage}</p>
        </div>
      </div>
    );
  }
}

export default ResponseCard;
