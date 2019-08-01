const bigExport = require("firestore-to-bigquery-export");
const helpers = require("./helpers_sample");

const admin = require("firebase-admin");
const serviceAccount = require("../secrets/pslove-dev-key.json");

//Initialize using the credentials json file....
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const firestore = admin.firestore();
const settings = { timestampsInSnapshots: true };
firestore.settings(settings);

//Constants
const datasetName = "users_data_for_analytics";

const collUsers = "users";
const collPredictors = "predictors";
const collOnboarding = "onboardings";
const collOrders = "orders";

//Set your bq to service account...
bigExport.setBigQueryConfig(serviceAccount);
bigExport.setFirebaseConfig(serviceAccount);

///Decides the batch size....
const threshold = 10; //8000

try {

  ///NOTE : ORDERS USES SECRETS TOO...FOR CHANGING NEED TO CHANGE HERE AND IN HELPERS_SAMPLE

  //Invokes the creating tables in BigQuery....
  // createTables();

  //Inserts the data in BigQuery Tables....
  // insertDataIntoUserTables();

  //Inserts the orders in BQ Table Order
  // insertOrders();

} catch (error) {
  console.error('ERROR while RUNNING >>>> ', error);
}

///////////////////////////////////////////CREATES TABLES///////////////////////////////////

//Creates the tables...
function createTables() {
  let dataToBeCreated = {
    datasetName: datasetName,
    // collectionName: [collUsers]
    collectionName: [collOrders]
  };

  helpers.createBQTables(dataToBeCreated);
}

//////////////////////////////////////////END CREATING TABLES///////////////////////////////

//Insert data into the tables...
async function insertDataIntoUserTables() {
  let dataToBeCreated = {
    datasetName: datasetName,
    collectionName: collUsers
  };

  helpers.insertDataInBQ(dataToBeCreated, firestore.collection(collUsers).get());

  // batching(dataToBeCreated, collUsers);
}

//Insert orders from FS to BQ...
async function insertOrders() {
  let dataForOrders = {
    datasetName: datasetName,
    collectionName: collOrders
  };

  // batchingForOrders(dataForOrders, collUsers);
}

async function batching(data, collection) {

  let totalDocs = await firestore.collection(`${collection}`).orderBy('created_at').get();

  let docsCount = totalDocs.docs.length;

  let reqdBatches = helpers.batchesCount(docsCount, threshold);
  console.log('\n\n******************************************************************');
  console.log('\n     Batches reqd ::::::::::::: ', reqdBatches);
  console.log('\n******************************************************************');

  let firstBatch = firestore.collection(`${collection}`).orderBy('created_at').limit(threshold);

  let paginate = await firstBatch.get();
  //Insert data in BQ >>>> First Batch
  helpers.insertDataInBQ(data, firstBatch.get());

  let batchLength = paginate.docs.length;

  // let batchLength = threshold;
  let firstLoop = true;
  let lastDoc;

  for (let index = 0; index < reqdBatches; index++) {

    if (firstLoop) {
      // Get the last document from firstBatch
      lastDoc = paginate.docs[batchLength - 1];
      console.log('\n     First batch ends at ::::::::::: ', lastDoc.id);
      console.log('\n******************************************************************\n\n');

      //Insert data in BQ >>>> First Batch
      // await helpers.insertDataInBQ(data, firestore.collection('users').orderBy('created_at').endBefore(lastDoc.data().created_at).limit(threshold).get());
    }

    let nextQuery = firestore.collection(`${collection}`).orderBy('created_at').startAfter(lastDoc.data().created_at).limit(threshold);

    //Insert data in BQ >>>> Subsequent Batches
    await helpers.insertDataInBQ(data, nextQuery.get());

    let nextBatch = await nextQuery.get();
    lastDoc = nextBatch.docs[nextBatch.docs.length - 1];

    console.log('     Next batch ends at  ::::::::::: ', nextBatch.docs[nextBatch.docs.length - 1].id);

    //Increment the batchLength
    batchLength += nextBatch.docs.length;
    console.log('     Next batch length   ::::::::::: ', nextBatch.docs.length, batchLength, '\n');
    firstLoop = false;
  }

  // for (let index = 0; index < reqdBatches; index++) {

  //   // console.log('Loop ', index, batchLength);
  //   let query = await firestore.collection('users').orderBy('created_at').limit(batchLength).get();

  //   // Get the last document from firstBatch
  //   let lastDoc = query.docs[batchLength - 1];
  //   console.log('Last doc', lastDoc.id);

  //   let nextQuery = firestore.collection('users').orderBy('created_at').startAfter(lastDoc.data().created_at).limit(threshold);
  //   let nextBatch = await nextQuery.get();

  //   //Increment the batchLength
  //   batchLength += nextBatch.docs.length;
  //   console.log('Next batch length', nextBatch.docs.length , batchLength);
  // }

  let remainingDocs = docsCount - batchLength;
  console.log('\n\n******************************* OPERATION STATS ********************************************');
  console.log('\n >>> TOTAL DOCS >>>>', docsCount);
  console.log('\n >>> BATCHED DOCS >>>>', batchLength);
  console.log('\n >>> NO. OF DOCS LEFT ACCIDENTALLY>>>>', remainingDocs);
  console.log('\n\n*******************************  THATS ALL FOLKS ********************************************\n');

  // paginate.forEach(async element => {
  //   // console.log('ID,  >>>>', element.id);
  // });

  // // Get the last document from firstBatch
  // let lastDoc = paginate.docs[batchLength - 1];

  // let nextQuery = firestore.collection('users').orderBy('created_at').startAfter(lastDoc.data().created_at).limit(threshold);
  // let nextBatch = await nextQuery.get();

  // // console.log('\n\n', nextBatch.docs.length);

  // nextBatch.forEach(async element => {
  //   // console.log('ID,  >>>>', element.id);
  // });
}

async function batchingForOrders(data, collection) {

  let totalDocs = await firestore.collection(`${collection}`).orderBy('created_at').get();

  let docsCount = totalDocs.docs.length;
  console.log('Docs count', docsCount);

  let usersWithOrders = 0;

  totalDocs.forEach(async element => {
    let docId = element.id;

    // console.log('ID >>>>>> ', docId);

    //Check if the user id has order collection
    let orderCollection = await firestore.collection(`${collection}`).doc(`${docId}`).collection('orders').get();

    let size = orderCollection.docs.length;
    if (size > 0) {
      // console.log(`Order collection present for ${docId}`);
      usersWithOrders++;

      let orderDocs = await firestore.collection(`${collection}`).doc(`${docId}`).collection('orders').get();

      //Additional Data for analysis....
      let addOnData = {
        user_doc_id: docId,
      };

      orderDocs.forEach(async element => {
        let orderDocId = element.id;
        console.log('Order info', orderDocId);

        let orderInfo = await firestore.collection(`${collection}`).doc(`${docId}`).collection('orders').doc(`${orderDocId}`).get();
        // let orderInfo = firestore.collection(`${collection}`).doc(`${docId}`).collection('orders').doc(`${orderDocId}`);
        // console.log('Order info', orderInfo.data());

        helpers.insertDataInBQForOrders(data, firestore.collection(`${collection}`).doc(`${docId}`).collection('orders').get(), addOnData);
      });
    }
  });

}