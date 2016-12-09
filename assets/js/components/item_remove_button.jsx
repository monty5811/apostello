import React, { Component, PropTypes } from 'react';
import post from '../utils/ajax_post';

class ItemRemoveButton extends Component {
  constructor() {
    super();
    this.archiveItem = this.archiveItem.bind(this);
  }
  archiveItem() {
    const success = () => { window.location.href = this.props.redirect_url; };
    post(
      this.props.url,
      { archived: this.props.is_archived },
      success,
    );
  }
  render() {
    let txt = 'Remove';
    let className = 'ui fluid negative button';
    if (this.props.is_archived) {
      txt = 'Restore';
      className = 'ui fluid positive button';
    }
    return (<div className={className} onClick={this.archiveItem}>{txt}</div>);
  }
}

ItemRemoveButton.propTypes = {
  url: PropTypes.string.isRequired,
  redirect_url: PropTypes.string.isRequired,
  is_archived: PropTypes.bool.isRequired,
};

export default ItemRemoveButton;
