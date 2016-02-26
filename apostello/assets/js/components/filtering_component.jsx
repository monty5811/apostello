import React, { Component } from 'react';

function obj2str(obj) {
  const vals = Object.keys(obj).map(
    key => {
      let val = obj[key];
      if (typeof(val) === 'object') {
        val = obj2str(val);
      }
      return val;
    }
  );
  return vals.join();
}

export const FilteringComponent = ComposedComponent => class extends Component {
  constructor() {
    super();
    this._onChange = this._onChange.bind(this);
    this.state = { filterRegex: new RegExp('', 'img') };
  }
  _onChange(e) {
    this.setState({ filterRegex: new RegExp(e.target.value, 'img') });
  }
  render() {
    let filteredData = this.props.data;
    filteredData = filteredData.filter(
      (el) => {
        const valsStr = obj2str(el);
        return valsStr.search(this.state.filterRegex) > -1;
      }
    );
    return (
      <div>
        <div className="ui left icon large transparent fluid input">
          <input type="text" placeholder="Filter..." onChange={this._onChange} />
          <i className="violet filter icon"></i>
        </div>

        <ComposedComponent
          {...this.props}
          data={filteredData}
        />
      </div>
    );
  }
};
