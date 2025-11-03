'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "f45c4dfa75dd1cb71b8308e487751ddf",
"version.json": "aa73e31dff5c68a52ed22f79d5f7ebd8",
"index.html": "5f5061a14943177a0cdacb137b425525",
"/": "5f5061a14943177a0cdacb137b425525",
"main.dart.js": "82e0436dcb657e65023c3f3eae4b2cf4",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "82a7248ff2cedaf3556857432a97c606",
"assets/AssetManifest.json": "4f2f1e90cda11e4683b8b43fcb51e4aa",
"assets/NOTICES": "1fa32da337faa943f218ebcb60b1b6d5",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "579a1958ae5d436d50b40561c87954cb",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "76c00c46b4965b484c879e22b5a7e54c",
"assets/fonts/MaterialIcons-Regular.otf": "09596ae87b9c60a968f1d234510844a5",
"assets/assets/images/logo.jpg": "0c94579ef1fcd1614fabf88357af5f5c",
"assets/assets/results/models.json": "ae11798f89485a30f2374f050e0e50cb",
"assets/assets/results/gpt-5-mini_20251024_045213/HMMTFeb2025.json": "5a8c5778de5f3fd932fef2974f57f96b",
"assets/assets/results/gpt-5-mini_20251024_045213/costs_and_latencies.json": "0b16b6fba29aab25ed612c7f6425d233",
"assets/assets/results/gpt-5-mini_20251024_045213/HMMTFeb2024.json": "31667e88be05e5e90e7f165cab8941dc",
"assets/assets/results/gpt-5-mini_20251024_045213/CharXiv.json": "0a46f6c74364f41074b71cc3b339da97",
"assets/assets/results/gpt-5-mini_20251024_045213/AIME2025.json": "65cf31088efbe0c7345c7ec684b8a1d2",
"assets/assets/results/gpt-5-mini_20251024_045213/MMLU-Pro.json": "04a717a87403568b7dc0a63ab4f1e399",
"assets/assets/results/gpt-5-mini_20251024_045213/AIME2024.json": "02692436d8e3400e12fb984c95349ae1",
"assets/assets/results/gpt-5-mini_20251024_045213/HLE.json": "abac6a4446cd81c9f5a58dd3d1102aff",
"assets/assets/results/gpt-5-mini_20251024_045213/MMMU.json": "d96b46033a556dea4e20f7afa4d126ba",
"assets/assets/results/gpt-5-mini_20251024_045213/COLLIE.json": "4064e989bb2483d058187c0a46e34295",
"assets/assets/results/gpt-5-mini_20251024_045213/CMIMC2025.json": "fc7a83f19a396c2e41c73539ecd04df0",
"assets/assets/results/gpt-5-mini_20251024_045213/MMMU-Pro.json": "2984d71f762ce49c6271f74d19f5d601",
"assets/assets/results/gpt-5-mini_20251024_045213/GPQA-Diamond.json": "3a9774e30ab4c1c319a70b34b8ddf4c2",
"assets/assets/results/gpt-5-mini_20251024_045213/BRUMO2025.json": "64f308dd881965d2d220f462e743f57f",
"assets/assets/results/gpt-5-mini_20251024_045213/SimpleQA.json": "181df9e4b06119256fa84bfa309dcfb6",
"assets/assets/results/gpt-5-mini_20251024_045213/final_results.json": "72afbe7ae4891822b9b4f69bf064779e",
"assets/assets/results/gpt-5-nano_20251030_052520/costs_and_latencies.json": "a047d6951e34e2ce76cb9a9fd2e1a070",
"assets/assets/results/gpt-5-nano_20251030_052520/CharXiv.json": "0a7213eaf3725cc31ffce2e809e4551b",
"assets/assets/results/gpt-5-nano_20251030_052520/final_results.json": "d969fb6e1b3d788c29bbc9cd33952f2c",
"assets/assets/results/gpt-4-mini_fake_20251024_045213/HMMTFeb2025.json": "5a8c5778de5f3fd932fef2974f57f96b",
"assets/assets/results/gpt-4-mini_fake_20251024_045213/HMMTFeb2024.json": "31667e88be05e5e90e7f165cab8941dc",
"assets/assets/results/gpt-4-mini_fake_20251024_045213/CharXiv.json": "0a46f6c74364f41074b71cc3b339da97",
"assets/assets/results/gpt-4-mini_fake_20251024_045213/AIME2025.json": "65cf31088efbe0c7345c7ec684b8a1d2",
"assets/assets/results/gpt-4-mini_fake_20251024_045213/MMLU-Pro.json": "04a717a87403568b7dc0a63ab4f1e399",
"assets/assets/results/gpt-4-mini_fake_20251024_045213/AIME2024.json": "02692436d8e3400e12fb984c95349ae1",
"assets/assets/results/gpt-4-mini_fake_20251024_045213/HLE.json": "abac6a4446cd81c9f5a58dd3d1102aff",
"assets/assets/results/gpt-4-mini_fake_20251024_045213/MMMU.json": "d96b46033a556dea4e20f7afa4d126ba",
"assets/assets/results/gpt-4-mini_fake_20251024_045213/COLLIE.json": "4064e989bb2483d058187c0a46e34295",
"assets/assets/results/gpt-4-mini_fake_20251024_045213/CMIMC2025.json": "fc7a83f19a396c2e41c73539ecd04df0",
"assets/assets/results/gpt-4-mini_fake_20251024_045213/MMMU-Pro.json": "2984d71f762ce49c6271f74d19f5d601",
"assets/assets/results/gpt-4-mini_fake_20251024_045213/GPQA-Diamond.json": "3a9774e30ab4c1c319a70b34b8ddf4c2",
"assets/assets/results/gpt-4-mini_fake_20251024_045213/BRUMO2025.json": "64f308dd881965d2d220f462e743f57f",
"assets/assets/results/gpt-4-mini_fake_20251024_045213/SimpleQA.json": "181df9e4b06119256fa84bfa309dcfb6",
"assets/assets/results/gpt-4-mini_fake_20251024_045213/final_results.json": "72afbe7ae4891822b9b4f69bf064779e",
"assets/assets/results/gpt-3-mini_fake_20251024_045213/HMMTFeb2025.json": "5a8c5778de5f3fd932fef2974f57f96b",
"assets/assets/results/gpt-3-mini_fake_20251024_045213/costs_and_latencies.json": "4337792bb9cf1c6539327ac0d3086bbf",
"assets/assets/results/gpt-3-mini_fake_20251024_045213/HMMTFeb2024.json": "31667e88be05e5e90e7f165cab8941dc",
"assets/assets/results/gpt-3-mini_fake_20251024_045213/CharXiv.json": "0a46f6c74364f41074b71cc3b339da97",
"assets/assets/results/gpt-3-mini_fake_20251024_045213/AIME2025.json": "65cf31088efbe0c7345c7ec684b8a1d2",
"assets/assets/results/gpt-3-mini_fake_20251024_045213/MMLU-Pro.json": "04a717a87403568b7dc0a63ab4f1e399",
"assets/assets/results/gpt-3-mini_fake_20251024_045213/AIME2024.json": "02692436d8e3400e12fb984c95349ae1",
"assets/assets/results/gpt-3-mini_fake_20251024_045213/HLE.json": "abac6a4446cd81c9f5a58dd3d1102aff",
"assets/assets/results/gpt-3-mini_fake_20251024_045213/MMMU.json": "d96b46033a556dea4e20f7afa4d126ba",
"assets/assets/results/gpt-3-mini_fake_20251024_045213/COLLIE.json": "4064e989bb2483d058187c0a46e34295",
"assets/assets/results/gpt-3-mini_fake_20251024_045213/CMIMC2025.json": "fc7a83f19a396c2e41c73539ecd04df0",
"assets/assets/results/gpt-3-mini_fake_20251024_045213/MMMU-Pro.json": "2984d71f762ce49c6271f74d19f5d601",
"assets/assets/results/gpt-3-mini_fake_20251024_045213/GPQA-Diamond.json": "3a9774e30ab4c1c319a70b34b8ddf4c2",
"assets/assets/results/gpt-3-mini_fake_20251024_045213/BRUMO2025.json": "64f308dd881965d2d220f462e743f57f",
"assets/assets/results/gpt-3-mini_fake_20251024_045213/SimpleQA.json": "181df9e4b06119256fa84bfa309dcfb6",
"assets/assets/results/gpt-3-mini_fake_20251024_045213/final_results.json": "94c1d0338d94ff09992c87e6d8a4a433",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
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
