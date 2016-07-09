import React, { Component } from 'react';
import $ from 'jquery';
import localforage from 'localforage';
import Loader from './loader';

export const LoadingComponent = ComposedComponent => class extends Component {
  constructor() {
    super();
    this.loadFromStorage = this.loadFromStorage.bind(this);
    this.loadFromServer = this.loadFromServer.bind(this);
    this.deleteItemUpdate = this.deleteItemUpdate.bind(this);
    this.state = { data: 'loading' };
  }
  loadFromStorage() {
    if (this.state.data !== 'loading') {
      // only load from storage when table is empty
      return;
    }
    localforage.getItem(this.props.url).then((value) => {
      if (value === null) {
        // no data in store yet, skip
        return;
      }
      const curData = new Map();
      value.results.map(x => curData.set(x.pk, x));
      if (this.state.data === 'loading') {
        // only update state if we are still 'loading'
        // we do not want to override any results that we
        // have already got from the server
        this.setState({ data: curData });
      }
    });
  }
  loadFromServer() {
    const that = this;
    $.ajax({
      url: that.props.url,
      dataType: 'json',
      success(data) {
        let curData = that.state.data;
        if (curData === 'loading') {
          curData = new Map();
        }
        data.results.map(x => curData.set(x.pk, x));

        that.setState({ data: curData });
        if (data.prev === null) {
          // first page - drop it in storage for the next
          // page load
          // this will also be called after any posts to the
          // server, which should minimise stale data on reload
          localforage.setItem(that.props.url, data);
        }
        if (data.next) {
          // if there is another page, grab it
          that.fetchNextPage(data.next);
        }
      },
      error(xhr, status, err) {
        console.error(that.props.url, status, err.toString());
      },
    });
  }
  fetchNextPage(url) {
    const that = this;
    $.ajax({
      url,
      dataType: 'json',
      success(data) {
        // update the items
        const curData = that.state.data;
        data.results.map(x => curData.set(x.pk, x));
        that.setState({ data: curData });
        if (data.next) {
          // if there is another page, grab it
          that.fetchNextPage(data.next);
        }
      },
      error(xhr, status, err) {
        console.error(url, status, err.toString());
      },
    });
  }
  deleteItemUpdate(data) {
    // remove item from Map and then pull from server
    const curData = this.state.data;
    curData.delete(data.pk);
    this.setState({ data: curData });
    this.loadFromServer();
  }
  componentDidMount() {
    this.loadFromStorage();
    this.loadFromServer();
    setInterval(this.loadFromServer, this.props.pollInterval);
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
