import ReactDOM from 'react-dom';
import React from 'react';
import ItemRemoveButton from './components/item_remove_button';

/* global _url, _redirect_url, _is_archived */

ReactDOM.render(
  React.createElement(ItemRemoveButton, {
    url: _url,
    redirect_url: _redirect_url,
    is_archived: _is_archived,
  }),
  document.getElementById('toggle_button')
);
