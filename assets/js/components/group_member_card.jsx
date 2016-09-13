import React, { Component, PropTypes } from 'react';

class MemberCard extends Component {
  constructor() {
    super();
    this.onClick = this.onClick.bind(this);
  }
  onClick() {
    const payload = {
      member: this.props.isMember,
      contactPk: this.props.contact.pk,
    };
    this.props.postUpdate(payload);
  }
  render() {
    return (
      <div className="ui raised card" onClick={this.onClick}>
        <div className="content">
          {this.props.contact.full_name}
        </div>
      </div>
    );
  }
}

MemberCard.propTypes = {
  contact: PropTypes.object.isRequired,
  isMember: PropTypes.bool.isRequired,
  postUpdate: PropTypes.func.isRequired,
};

export default MemberCard;
