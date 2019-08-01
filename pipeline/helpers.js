const { BigQuery } = require('@google-cloud/bigquery');
const bigqueryClient = new BigQuery();
const bigExport = require('firestore-to-bigquery-export');

///Decides the batch size....
const threshold = 8000;

/**
 * Deletes the big query tables...
 * @param {Object} body
 */
exports.deleteBQTables = async (body) => {
    let dataSetName = body.datasetName;
    let collectionName = body.collectionName;

    await bigqueryClient
        .dataset(dataSetName)
        .table(collectionName)
        .delete();

    console.log(`👺 👺 Table ${collectionName} deleted.`);
}

/**
 * Creates the big query tables...
 * @param {Object} body
 */
exports.createBQTables = async (body, firestore) => {
    let dataSetName = body.datasetName;
    let collectionArray = body.collectionName;

    let collectionName = collectionArray[0];

    bigExport.createBigQueryTables(dataSetName, collectionArray).then(res => {
        console.log(`😋 😋 Table ${collectionArray} created.`);

        // firestore.collection(`${collectionName}`).get()
        //     .then(snapshot => bigExport.copyToBigQuery(dataSetName, collectionName, snapshot))
        //     .then(res => {
        //         console.log('Copied ' + res + ' documents to BigQuery. Collection : ', collectionName);
        //     })
        //     .catch(error => console.error(error))
    })
        .catch(error => console.error(error))
}

/**
* Divide the documents into number of batches as per threshold...
* @param {int} count
*/
function batchesCount(count, threshold) {
    let batchesReqd = Math.ceil(count / threshold) - 1;
    if (batchesReqd < 0) {
        return 0;
    }
    return batchesReqd;
}

/**
* Start inserting in bq as per batches...
* @param {object} data
* @param {string} collection
*/
exports.batching = async (data, collection, firestore) => {

    let totalDocs = await firestore.collection(`${collection}`).orderBy('created_at').get();

    let docsCount = totalDocs.docs.length;

    let reqdBatches = batchesCount(docsCount, threshold);
    console.log(`\n     Batches reqd  ${collection} ::::::::::::: `, reqdBatches);

    let firstBatch = firestore.collection(`${collection}`).orderBy('created_at').limit(threshold);

    let paginate = await firstBatch.get();

    //Insert data in BQ >>>> First Batch
    insertDataInBQ(data, firstBatch.get());

    let batchLength = paginate.docs.length;

    let firstLoop = true;
    let lastDoc;

    for (let index = 0; index < reqdBatches; index++) {

        if (firstLoop) {
            // Get the last document from firstBatch
            lastDoc = paginate.docs[batchLength - 1];
            // await insertDataInBQ(data, firestore.collection(`${collection}`).orderBy('created_at').endBefore(lastDoc.data().created_at).limit(threshold).get());
        }

        let nextQuery = firestore.collection(`${collection}`).orderBy('created_at').startAfter(lastDoc.data().created_at).limit(threshold);

        //Insert data in BQ >>>> Subsequent Batches
        await insertDataInBQ(data, nextQuery.get());

        let nextBatch = await nextQuery.get();
        lastDoc = nextBatch.docs[nextBatch.docs.length - 1];

        //Increment the batchLength
        batchLength += nextBatch.docs.length;
        firstLoop = false;
    }
    console.log(`\n >>> TOTAL DOCS ${collection}>>>>`, docsCount);
}



/**
* Insert the data into tables...
* @param {Object} body
* @param {instance} firestore instance
*/
function insertDataInBQ(body, firestore) {

    let dataSetName = body.datasetName;
    let collectionArray = body.collectionName;

    let collectionName = collectionArray[0];

    console.log('>>>', dataSetName, '>>>', collectionName);

    firestore
        .then(snapshot => bigExport.copyToBigQuery(dataSetName, collectionName, snapshot))
        .then(res => {
            console.log('Copied ' + res + ' documents to BigQuery for ' + collectionName + '.')
        })
        .catch(error => console.error(error))

}
