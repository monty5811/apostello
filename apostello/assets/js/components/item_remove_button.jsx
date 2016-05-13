import React, { Component } from 'react';
import post from './../ajax_post';

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
      success
    );
  }
  render() {
    let txt = 'Remove';
    let className = 'ui negative button';
    if (this.props.is_archived) {
      txt = 'Restore';
      className = 'ui positive button';
    }
    return (<div className={className} onClick={this.archiveItem}>{txt}</div>);
  }
}

export default ItemRemoveButton;
