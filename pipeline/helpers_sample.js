const bigExport = require('firestore-to-bigquery-export');
const { BigQuery } = require("@google-cloud/bigquery");
const serviceAccountFile = require("../secrets/pslove-dev-key.json");

const bigQuery = new BigQuery({
    projectId: serviceAccountFile.project_id,
    credentials: serviceAccountFile
})

const collUsers = 'users';
const collPredictors = 'predictors';
const collOnboarding = 'onboardings';

let currentRow = {};

/**
 * Creates the big query tables...
 * @param {Object} body
 */
exports.createBQTables = async (body) => {

    let dataSetName = body.datasetName;
    let collectionArray = body.collectionName;

    bigExport.createBigQueryTables(dataSetName, collectionArray).then(res => {
        console.log('Result is >>>>', res);
    })
        .catch(error => console.error(error))

}


/**
* Insert the data into tables...
* @param {Object} body
* @param {instance} firestore instance
*/
exports.insertDataInBQ = async (body, firestore) => {

    let dataSetName = body.datasetName;
    let collectionName = body.collectionName;

    console.log('>>>', dataSetName, '>>>', collectionName);

    ///FOR THE LIMIT
    // firestore.collection(`${collUsers}`).limit(9000).get()
    //     .then(snapshot => bigExport.copyToBigQuery(dataSetName, collectionName, snapshot))
    //     .then(res => {
    //         console.log('Copied ' + res + ' documents to BigQuery.')
    //     })
    //     .catch(error => console.error(error))

    //CURRENTLY IN PROD UNCOMMENT THIS
    firestore
        .then(snapshot => bigExport.copyToBigQuery(dataSetName, collectionName, snapshot))
        .then(res => {
            console.log('Copied ' + res + ' documents to BigQuery.')
        })
        .catch(error => console.error(error))
}

/**
* Insert the data into tables...
* @param {Object} body
* @param {instance} firestore instance
* @param {Object} User collection data
*/
exports.insertDataInBQForOrders = async (body, firestore, userData) => {

    let dataSetName = body.datasetName;
    let collectionName = body.collectionName;

    // console.log('>>>', dataSetName, '>>>', collectionName, '>>>>', userData);

    //MODIFYING SCHEMA >>> TRIAL
    firestore
        .then(snapshot => customCopyInBQ(dataSetName, collectionName, snapshot, userData))
        .then(res => {
            console.log('Copied ' + res + ' documents to BigQuery.')
        })
        .catch(error => console.error(error))

}

/**
* Divide the documents into number of batches as per threshold...
* @param {int} count
*/
exports.batchesCount = (count, threshold) => {
    let batchesReqd = Math.ceil(count / threshold) - 1;
    if (batchesReqd < 0) {
        return 0;
    }
    return batchesReqd;
}

function customCopyInBQ(datasetID, collectionName, snapshot, userData) {
    let counter = 0
    const rows = []

    for (let i = 0; i < snapshot.docs.length; i++) {

        //User id....
        const userId = userData.user_doc_id;

        const docID = snapshot.docs[i].id,
            data = snapshot.docs[i].data()

        currentRow = {}

        Object.keys(data).forEach(propName => {
            currentRow['doc_ID'] = docID
            currentRow['user_doc_ID'] = userId

            const formattedProp = formatProp(data[propName], propName)
            if (formattedProp) currentRow[formatName(propName)] = formattedProp
        })

        rows.push(currentRow)
        counter++
    }
    // console.log(currentRow.doc_ID, currentRow.user_doc_ID);
    // return null;
    return bigQuery.dataset(datasetID).table(collectionName).insert(rows)
        .then(() => {
            return counter
        })
        .catch(e => {
            console.log(`\n\nError while saving for order ID ${currentRow.doc_ID} and user doc ID ${currentRow.user_doc_ID}\n\n`);
            throw new Error(e)
        })
}

function formatProp(val, propName, parent) {
    if (val === null || typeof val === 'number' || typeof val === 'string') return val

    const name = formatName(propName, parent)

    if (Array.isArray(val)) {
        for (let i = 0; i < val.length; i++) {
            const formattedProp = formatProp(val[i], i, name)
            if (formattedProp !== undefined) currentRow[formatName(i, name)] = formattedProp
        }
    }
    else if (typeof val === 'object' && Object.keys(val).length) {
        Object.keys(val).forEach(subPropName => {
            const formattedProp = formatProp(val[subPropName], subPropName, name)
            if (formattedProp !== undefined) currentRow[formatName(subPropName, name)] = formattedProp
        })
        return undefined
    }
}

function formatName(propName, parent = undefined) {
    return parent ? parent + '__' + propName : propName
}

 //Insert data in tables result
 //Copied 7058 documents to BigQuery.
 //Copied 6638 documents to BigQuery
 //Copied 6972 documents to BigQuery.
