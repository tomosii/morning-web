'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"version.json": "ceba8deea4b68c683aecd011f70b8155",
"favicon.ico": "2730247e0353bbc1c4a06f6af0e494e7",
"index.html": "0f434c4ea0b22b68314ea474cd82f80d",
"/": "0f434c4ea0b22b68314ea474cd82f80d",
"main.dart.js": "c7b0cf25c1bc66fa8f9fea3b5085e8a7",
"flutter.js": "6fef97aeca90b426343ba6c5c9dc5d4a",
"site.webmanifest": "81ed62e622d323c69d920ff2f72b072d",
"icons/favicon-16x16.png": "6b23e52d64a0d5df4f0d4ae1f17f4b48",
"icons/safari-pinned-tab.svg": "d86679b90d49011fc0e9ec8600ac6dd2",
"icons/android-chrome-192x192.png": "5d0faaefe125c2c18c4a87cfa09add4c",
"icons/apple-touch-icon.png": "634e76abe4612f240343b23d38332e04",
"icons/android-chrome-512x512.png": "82d76f89f31c36db722aca1605d82510",
"icons/mstile-150x150.png": "c73cd2b9c0a8adcece3d437d4ffa6a56",
"icons/favicon-32x32.png": "358a625f68b1bbde89c4e921a529a3f1",
"assets/AssetManifest.json": "216aeafa89df8ac8b04ab73157b5c787",
"assets/NOTICES": "b59cd632a223e9125fed497e6e7f01be",
"assets/FontManifest.json": "b1441400673560c2e2d3a1e27fe74f3f",
"assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"assets/AssetManifest.bin": "cd7af5dea008d39b4dd56e1ba44640e9",
"assets/fonts/MaterialIcons-Regular.otf": "128fce298401ff685c7444dfbbf78ee8",
"assets/assets/images/morning-logo.png": "3bfdc7fa9684d268eca5199faef4858d",
"assets/assets/fonts/NotoSansJP-Bold.ttf": "4aec04fd98881db5fbc79075428727ef",
"assets/assets/fonts/NotoSansJP-Thin.ttf": "2361e7d2fb980b4fbf696ccdf4dcd1b1",
"assets/assets/fonts/NotoSansJP-ExtraBold.ttf": "bbb303ee75d437b96eaa696d283d9348",
"assets/assets/fonts/NotoSansJP-Medium.ttf": "818eefff2fa0b989124d9ba3a84f073c",
"assets/assets/fonts/NotoSansJP-Regular.ttf": "022f32abf24d5534496095e04aa739b3",
"assets/assets/fonts/NotoSansJP-Light.ttf": "7d1e0e68062ba3ae1cc12009620f645d",
"assets/assets/fonts/NotoSansJP-Black.ttf": "0938466177f003e69b3c2282ced133f9",
"assets/assets/fonts/NotoSansJP-SemiBold.ttf": "2f9b41d9040065bcce6ad91656732829",
"assets/assets/fonts/NotoSansJP-ExtraLight.ttf": "1bf5589e8c81cbc667f6db24e2c72846",
"browserconfig.xml": "a493ba0aa0b8ec8068d786d7248bb92c",
"canvaskit/skwasm.js": "95f16c6690f955a45b2317496983dbe9",
"canvaskit/skwasm.wasm": "d1fde2560be92c0b07ad9cf9acb10d05",
"canvaskit/chromium/canvaskit.js": "96ae916cd2d1b7320fff853ee22aebb0",
"canvaskit/chromium/canvaskit.wasm": "1165572f59d51e963a5bf9bdda61e39b",
"canvaskit/canvaskit.js": "bbf39143dfd758d8d847453b120c8ebb",
"canvaskit/canvaskit.wasm": "19d8b35640d13140fe4e6f3b8d450f04",
"canvaskit/skwasm.worker.js": "51253d3321b11ddb8d73fa8aa87d3b15"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
