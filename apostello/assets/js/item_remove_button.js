import ReactDOM from 'react-dom';
import React from 'react';
import ItemRemoveButton from './components/item_remove_button';

function renderToggleButton() {
  const buttonDiv = document.getElementById('toggle_button');
  ReactDOM.render(
    React.createElement(ItemRemoveButton, {
      url: buttonDiv.getAttribute('postUrl'),
      redirect_url: buttonDiv.getAttribute('redirectUrl'),
      is_archived: buttonDiv.getAttribute('viewingArchive'),
    }),
    buttonDiv
  );
}

export { renderToggleButton };
