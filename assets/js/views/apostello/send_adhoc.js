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
        forceSelection: false,
        fullTextSearch: true,
        onChange(text) {
          setCost(text.length, sms_cost);
        },
      },
    );

    $('#id_content').keyup(() => {
      const nPeople = $('.delete.icon').length;
      setCost(nPeople, sms_cost);
    });
  }
};
