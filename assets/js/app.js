import $ from 'jquery';
import renderElm from './utils/render_elm';
import renderFab from './utils/render_fab';
import initDateTimePickers from './utils/init_dt';
import initDropdowns from './utils/init_dropdowns';
import setCost from './utils/calculate_sms_cost';

/* global group_sizes, sms_cost */

function handleDOMContentLoaded() {
  // setup fab
  renderFab();
  // get page id
  const pageId = document.getElementsByTagName('body')[0].dataset.jsViewName;
  // start elm
  renderElm();
  // init dropdowns
  initDropdowns();
  // init datepickers
  initDateTimePickers();
  // init sms cost indicators
  if (pageId === 'apostello/send_adhoc') {
    $('#id_content').keyup(() => {
      const nPeople = $('.delete.icon').length;
      setCost(nPeople, sms_cost);
    });
  }
  if (pageId === 'apostello/send_group') {
    $('#id_content').keyup(() => {
      let nPeople = 0;
      const selectedGroup = $('.item.active.selected')[0];
      if (selectedGroup !== undefined) {
        nPeople = group_sizes[selectedGroup.getAttribute('data-value')];
      }
      setCost(nPeople, sms_cost);
    });
  }
}

window.addEventListener('DOMContentLoaded', handleDOMContentLoaded, false);
