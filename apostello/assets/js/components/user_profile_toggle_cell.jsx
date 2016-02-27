import React, { Component } from 'react';

class BooleanButton extends Component {
  constructor() {
    super();
    this._onClick = this._onClick.bind(this);
  }
  _onClick() {
    const user = this.props.user;
    user[this.props.field] = !user[this.props.field];
    console.log(user)
    this.props.postUpdate(user);
  }
  render() {
    let buttonType = 'negative';
    let iconType = 'minus circle';
    if (this.props.user[this.props.field]) {
      buttonType = 'positive';
      iconType = 'checkmark';
    }
    return (
      <td>
        <button className={`ui tiny ${buttonType} icon button`} onClick={this._onClick}>
          <i className={`${iconType} icon`} />
        </button>
      </td>
    );
  }
}

export default BooleanButton;
