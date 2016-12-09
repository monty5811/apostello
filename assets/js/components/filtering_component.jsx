import React, { Component, PropTypes } from 'react';

function obj2str(obj) {
  if (obj === null) {
    return '';
  }
  const vals = Object.keys(obj).map(
    (key) => {
      let val = obj[key];
      if (typeof val === 'object') {
        val = obj2str(val);
      }
      return val;
    },
  );
  return vals.join();
}

const FilteringComponent = ComposedComponent => class extends Component {
  static propTypes() {
    return {
      data: PropTypes.array.isRequired,
    };
  }
  constructor() {
    super();
    this.onChange = this.onChange.bind(this);
    this.state = { filterRegex: new RegExp('', 'img') };
  }
  onChange(e) {
    this.setState({ filterRegex: new RegExp(e.target.value, 'img') });
  }
  render() {
    let filteredData = this.props.data;
    filteredData = filteredData.filter(
      (el) => {
        const valsStr = obj2str(el);
        return valsStr.search(this.state.filterRegex) > -1;
      },
    );
    return (
      <div>
        <div className="ui left icon large transparent fluid input">
          <input type="text" placeholder="Filter..." onChange={this.onChange} />
          <i className="violet filter icon" />
        </div>

        <ComposedComponent
          {...this.props}
          data={filteredData}
        />
      </div>
    );
  }
};

export default FilteringComponent;
