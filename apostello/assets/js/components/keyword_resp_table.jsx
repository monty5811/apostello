import React, { Component } from 'react';
import post from './../ajax_post';
import { LoadingComponent } from './reloading_component';
import { FilteringComponent } from './filtering_component';
import KeywordRespRow from './keyword_resp_row';

class KeywordRespTable extends Component {
  constructor() {
    super();
    this.archiveSms = this.archiveSms.bind(this);
    this.dealWithSms = this.dealWithSms.bind(this);
  }
  archiveSms(sms) {
    post(
      `/api/v1/sms/in/${sms.pk}`,
      { archive: !sms.is_archived },
      this.props.deleteItemUpdate
    );
  }
  dealWithSms(sms) {
    post(
      `/api/v1/sms/in/${sms.pk}`,
      { deal_with: !sms.dealt_with },
      this.props.loadfromserver
    );
  }
  render() {
    const that = this;
    const rows = this.props.data.map(
      (sms, index) => <KeywordRespRow
        sms={sms}
        key={index}
        archiveSms={that.archiveSms}
        dealtWithSms={that.dealWithSms}
        viewingArchive={that.viewingArchive}
      />
    );
    return (
      <table className="ui table">
        <thead>
          <tr>
            <th>From</th>
            <th>Time Received</th>
            <th>Message</th>
            <th>Requires Action?</th>
            <th></th>
          </tr>
        </thead>
        <tbody className="searchable">
          {rows}
        </tbody>
      </table>
    );
  }
}

export default LoadingComponent(FilteringComponent(KeywordRespTable));
