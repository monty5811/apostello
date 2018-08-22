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
