// Minimal updater worker that imports the OneSignal SDK worker.
// OneSignal recommends shipping both OneSignalSDKWorker.js and
// OneSignalSDKUpdaterWorker.js at the site root. The main worker file
// (OneSignalSDKWorker.js) should already be present in the `web/` directory.

importScripts('https://cdn.onesignal.com/sdks/OneSignalSDKWorker.js');
