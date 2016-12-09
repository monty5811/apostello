import React, { Component, PropTypes } from 'react';
import $ from 'jquery';
import biu from 'biu.js';
import Loader from './loader';

const LoadingComponent = ComposedComponent => class extends Component {
  static propTypes() {
    return {
      url: PropTypes.string.isRequired,
    };
  }
  constructor() {
    super();
    this.fetchPage = this.fetchPage.bind(this);
    this.fetchNextPage = this.fetchNextPage.bind(this);
    this.loadFromServer = this.loadFromServer.bind(this);
    this.deleteItemUpdate = this.deleteItemUpdate.bind(this);
    this.state = { data: 'loading' };
    this.timers = [];
    this.fetches = [];
  }
  fetchNextPage(data) {
    // by the time we are here, we know there are more items to fetch
    // the first page should fetch 10 items so the page loads quickly
    // then we increase to 100, then 1000
    // once at 1000, we use the next page provided by the server
    const numVals = data.results.length;
    if (numVals < 11) {
      // we have fetched the first page, let's bump page size to 100
      this.fetchPage(`${this.props.url}?page_size=100`);
      return;
    }
    if (numVals > 10 && numVals < 101) {
      // we have used page size 100, let's up it to 1000
      this.fetchPage(`${this.props.url}?page_size=1000`);
      return;
    }
    if (numVals > 100) {
      // we have used page size 1000, let's fetch server's "next"
      this.fetchPage(data.next);
    }
  }
  fetchPage(url) {
    const that = this;
    this.fetches.push(
      $.ajax({
        url,
        dataType: 'json',
        success(data) {
          let curData = that.state.data;
          if (curData === 'loading') {
            curData = new Map();
          }
          // update state
          data.results.map(x => curData.set(x.pk, x));
          that.setState({ data: curData });
          if (data.next && curData.size < 3000) {
            that.fetchNextPage(data);
          } else {
            // we have finished, let's wait, then update data again
            that.timers.push(
              setTimeout(that.loadFromServer, that.props.pollInterval),
            );
          }
        },
        error(xhr, status) {
          if (status !== 'abort') {
            biu('Uh oh. Something went wrong when we tried to update...', { type: 'warning' });
            that.timers.push(
              setTimeout(that.loadFromServer, 10 * that.props.pollInterval),
            );
          }
        },
      }),
    );
  }
  loadFromServer() {
    // stop any existing fetches and timers
    // this function will be called when a button is pressed
    // we do not want multiple timers running at the same time
    this.timers.forEach(t => clearTimeout(t));
    this.fetches.forEach(f => f.abort());
    this.fetches = [];
    // start reloading all data from server
    this.fetchPage(this.props.url);
  }
  deleteItemUpdate(data) {
    // remove item from Map and then pull from server
    const curData = this.state.data;
    curData.delete(data.pk);
    this.setState({ data: curData });
    // fetch from server again, but do not use local cache
    this.loadFromServer();
  }
  componentDidMount() {
    this.loadFromServer();
  }
  render() {
    if (this.state.data === 'loading') {
      return <Loader />;
    }
    return (
      <ComposedComponent
        {...this.props}
        data={Array.from(this.state.data.values())}
        loadfromserver={this.loadFromServer}
        deleteItemUpdate={this.deleteItemUpdate}
      />
    );
  }
};

export default LoadingComponent;
