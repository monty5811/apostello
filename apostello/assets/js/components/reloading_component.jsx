import React, { Component } from 'react';
import $ from 'jquery';
import Loader from './loader';

export const LoadingComponent = ComposedComponent => class extends Component {
  constructor() {
    super();
    this.loadFromServer = this.loadFromServer.bind(this);
    this.deleteItemUpdate = this.deleteItemUpdate.bind(this);
    this.state = { data: 'loading' };
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
