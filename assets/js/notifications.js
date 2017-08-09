function isSubscribed(port) {
  // TODO send id through port, not bool
  navigator.serviceWorker.ready.then(function(registration) {
    if (!registration.pushManager) {
      port.send({ noSupport: true });
    }
    registration.pushManager
      .getSubscription()
      .then(function(subscription) {
        if (!(subscription === null)) {
          port.send({ regValue: subscription.endpoint });
        } else {
          port.send({ regValue: null });
        }
      })
      .catch(function(error) {
        console.error(error);
        port.send({ failed: true });
      });
  });
}

function subscribePush(port) {
  navigator.serviceWorker.ready.then(function(registration) {
    if (!registration.pushManager) {
      console.log("Your browser doesn't support push notification.");
      port.send({ noSupport: true });
    }

    //To subscribe `push notification` from push manager
    registration.pushManager
      .subscribe({
        userVisibleOnly: true, //Always show notification when received
      })
      .then(function(subscription) {
        console.info('Push notification subscribed.');
        port.send({ regValue: subscription.endpoint });
      })
      .catch(function(error) {
        console.error('Push notification subscription error: ', error);
        port.send({ failed: true });
      });
  });
}

function unsubscribePush(port) {
  navigator.serviceWorker.ready.then(function(registration) {
    //Get `push subscription`
    registration.pushManager
      .getSubscription()
      .then(function(subscription) {
        //If no `push subscription`, then return
        if (!subscription) {
          console.log('Unable to unregister push notification.');
          port.send({ failed: true });
        }

        //Unsubscribe `push notification`
        subscription
          .unsubscribe()
          .then(function() {
            console.info('Push notification unsubscribed.');
            port.send({
              unregValue: subscription.endpoint,
            });
          })
          .catch(function(error) {
            console.error(error);
            port.send({ failed: true });
          });
      })
      .catch(function(error) {
        console.error('Failed to unsubscribe push notification.');
        port.send({ failed: true });
      });
  });
}

export { isSubscribed, subscribePush, unsubscribePush };
