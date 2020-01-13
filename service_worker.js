self.addEventListener('install', function (e) {
    e.waitUntil(
      caches.open('elmquotes').then(function (cache) {
        return cache.addAll([
          '/',
          '/elm.js',
          '/assets/images/dwyl.png',
        ]);
      })
    );
  });
  
  self.addEventListener('fetch', function (event) {
    event.respondWith(
      caches.match(event.request).then(function (response) {
        return response || fetch(event.request);
      })
    );
  });
  