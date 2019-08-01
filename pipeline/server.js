'use-strict';

const bodyParser = require('body-parser');
const express = require('express');

const app = express();
const admin = require('firebase-admin');

const pipeline = require('./index');

admin.initializeApp({
    projectId: 'pslove-usa',
    databaseURL: 'https://pslove-usa.firebaseio.com'
});

const firestore = admin.firestore();
const settings = { timestampsInSnapshots: true };
firestore.settings(settings);

//https://stackoverflow.com/questions/23413401/what-does-trust-proxy-actually-do-in-express-js-and-do-i-need-to-use-it
app.enable('trust proxy');

//https://medium.com/@adamzerner/how-bodyparser-works-247897a93b90
app.use(bodyParser.raw());
app.use(bodyParser.json());
app.use(bodyParser.text());

app.post('/api/pipeline', (req, res) => {
    // If working, you should see this!!!
    console.log('🙃 🙃 Inside GAE');

    res.send('Hello, GAE!').end();
    pipeline.streamFStoBQ(firestore);
});

// Start the server
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
    console.log(`Pipeline GAE listening on port ${PORT}`);
});

//https://github.com/googleapis/google-cloud-node/issues/1908
