import React, { Component } from 'react';
import $ from 'jquery';
import localforage from 'localforage';
import Loader from './loader';

export const LoadingComponent = ComposedComponent => class extends Component {
  constructor() {
    super();
    this.cacheThenReq = this.cacheThenReq.bind(this);
    this.fetchPage = this.fetchPage.bind(this);
    this.loadFromServer = this.loadFromServer.bind(this);
    this.deleteItemUpdate = this.deleteItemUpdate.bind(this);
    this.state = { data: 'loading' };
    this.timers = [];
    this.fetches = [];
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
          // cache the data
          localforage.setItem(url, data).then(() => {
            if (data.next) {
              // if there is another page, grab it
              that.getPage(data.next);
            } else {
              // we have finished, let's wait, then update data again
              that.timers.push(
                setTimeout(that.loadFromServer, that.props.pollInterval)
              );
            }
          });
        },
        error(xhr, status, err) {
          console.error(url, status, err.toString());
        },
      })
    );
  }
  cacheThenReq(url, useCache = true) {
    if (!useCache) {
      this.fetchPage(url);
      return;
    }
    localforage.getItem(url).then((value) => {
      if (value !== null) {
        // cache hit, update state
        let curData = this.state.data;
        if (this.state.data === 'loading') {
          curData = new Map();
        }
        value.results.map(x => curData.set(x.pk, x));
        this.setState({ data: curData });
      }
      // then make the request, overwrite data and update cache
      this.fetchPage(url);
    });
  }
  getPage(url, useCache = true) {
    this.cacheThenReq(url, useCache);
  }
  loadFromServer(useCache = true) {
    // stop any existing fetches and timers
    // this function will be called when a button is pressed
    // we do not want multiple timers running at the same time
    this.timers.forEach((t) => clearTimeout(t));
    this.fetches.forEach((f) => f.abort());
    this.fetches = [];
    // start reloading all data from server
    this.getPage(this.props.url, useCache);
  }
  deleteItemUpdate(data) {
    // remove item from Map and then pull from server
    const curData = this.state.data;
    curData.delete(data.pk);
    this.setState({ data: curData });
    // fetch from server again, but do not use local cache
    this.loadFromServer(false);
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
