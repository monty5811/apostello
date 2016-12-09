import $ from 'jquery';
import setCost from '../../utils/calculate_sms_cost';
import initDateTimePickers from '../../utils/init_dt';
import CommonView from '../common';

/* global group_sizes, sms_cost */

module.exports = class View extends CommonView {
  mount() {
    super.mount();

    initDateTimePickers();

    $('.field .dropdown').dropdown(
      {
        fullTextSearch: true,
        onChange(text) {
          setCost(group_sizes[text], sms_cost);
        },
      },
    );

    $('#id_content').keyup(() => {
      let nPeople = 0;
      const selectedGroup = $('.item.active.selected')[0];
      if (selectedGroup !== undefined) {
        nPeople = group_sizes[selectedGroup.getAttribute('data-value')];
      }
      setCost(nPeople, sms_cost);
    });
  }
};
