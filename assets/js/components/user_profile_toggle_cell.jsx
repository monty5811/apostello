import React, { Component } from 'react';

class BooleanButton extends Component {
  constructor() {
    super();
    this.onClick = this.onClick.bind(this);
  }
  onClick() {
    const user = this.props.user;
    user[this.props.field] = !user[this.props.field];
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
        <button className={`ui tiny ${buttonType} icon button`} onClick={this.onClick}>
          <i className={`${iconType} icon`} />
        </button>
      </td>
    );
  }
}

export default BooleanButton;
