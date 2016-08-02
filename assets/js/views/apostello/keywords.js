import KeywordsTable from '../../components/keywords_table';
import renderTable from '../../utils/render_table';
import CommonView from '../common';

module.exports = class View extends CommonView {
  mount() {
    super.mount();

    renderTable(KeywordsTable);
  }
};
