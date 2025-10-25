const functions = require('firebase-functions');
const admin = require('firebase-admin');
const https = require('https');

admin.initializeApp();

exports.getPoolStatus = functions.https.onRequest((req, res) => {
  // Set CORS headers
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  const url = 'https://svoemkbh.kk.dk/svoemmeanlaeg/svoemmehaller/sundby-bad';

  https.get(url, (response) => {
    let data = '';

    response.on('data', (chunk) => {
      data += chunk;
    });

    response.on('end', () => {
      // Parse the HTML to extract status (simplified)
      const statusMatch = data.match(/Driftsinfo[\s\S]*?<div[^>]*>(.*?)<\/div>/i);
      const status = statusMatch ? statusMatch[1].trim() : 'Unable to determine status';

      res.status(200).json({ status });
    });
  }).on('error', (err) => {
    console.error('Error fetching pool status:', err);
    res.status(500).json({ error: 'Failed to fetch pool status' });
  });
});