import React from 'react';

const ResponseCard = (props) => {
  const resp = props.response;
  const firstWord = resp.content.split(' ')[0];
  const restOfMessage = resp.content.split(' ').splice(1).join(' ');
  const styles = {
    backgroundColor: '#ffffff',
    fontSize: '200%',
  };
  return (
    <div className="card" style={styles}>
      <div className="content">
        <p>
          <span style={{ color: '#D3D3D3' }}>{firstWord}</span> {restOfMessage}
        </p>
      </div>
    </div>
  );
};

export default ResponseCard;
