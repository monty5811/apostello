{% load static %}
const CACHE_NAME = 'apostello-cache-v1';
const OFFLINE_URL = '/offline/?_';
const urlsToCache = [
  OFFLINE_URL,
  "{% static 'js/app.js' %}",
  "{% static 'css/apostello.min.css' %}",
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
    .then(function(cache) {
      return cache.addAll(urlsToCache)
    })
  );
});

self.addEventListener('fetch', function(event) {
  if (event.request.mode === 'navigate' ||
    (event.request.method === 'GET' && event.request.headers.get('accept').includes('text/html'))) {
    event.respondWith(
      fetch(event.request).catch(error => {
        return caches.match(OFFLINE_URL);
      }))
  } else {
  event.respondWith(
    caches.match(event.request)
      .then(function(response) {
        if (response) {
          return response;
        }
        return fetch(event.request);
      }
    )
  );
  }
});

self.addEventListener('activate', function(event) {
  const cacheWhitelist = [CACHE_NAME];
  event.waitUntil(
    caches.keys().then(function(keyList) {
      return Promise.all(keyList.map(function(key) {
        if (cacheWhitelist.indexOf(key) === -1) {
          return caches.delete(key);
        }
      }));
    })
  );
});

self.addEventListener('push', function(event) {
  console.log(event);
  var title = 'New apostello message';

  var body = {
    'body': 'Click to see in apostello',
    'tag': 'apostello',
    'icon': ".{% static 'images/favicons/android-chrome-48x48.png' %}",
  };

  event.waitUntil(
    self.registration.showNotification(title, body)
  );
});

self.addEventListener('notificationclick', function(event) {
  event.notification.close(); //Close the notification
  event.waitUntil(clients.openWindow('/incoming/'));
});
