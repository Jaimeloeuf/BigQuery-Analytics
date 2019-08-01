//BQ Helpers
const helpers = require("./helpers");

//BQ Constants
const datasetName = "users_data_for_analytics";

const bigExport = require("firestore-to-bigquery-export");
const serviceAccount = require('./secrets/pslove-usa-key.json');

//Set your bq to service account...
bigExport.setBigQueryConfig(serviceAccount);
bigExport.setFirebaseConfig(serviceAccount);

const { BigQuery } = require("@google-cloud/bigquery");
const bigqueryClient = new BigQuery();

const tablePredictors = "predictors";
const tableOnboardings = "onboardings";
const tableUsers = "users";


/**
 * Run once at midnight, to stream the Firestore collections (Users, Predictors, Onboardings)
 * Manually run the task here https://console.cloud.google.com/cloudscheduler
 */
exports.streamFStoBQ = async firestore => {
  console.log("🤫 🤫 Run every day at 12:45 AM UTC!");

  const [tables] = await bigqueryClient.dataset(datasetName).getTables();
  tables.forEach(async table => {
    let bgTables = table.id;

    switch (bgTables) {
      case tablePredictors:

        try {
          await deleteTable(tablePredictors);
          // await createTable([tablePredictors], firestore);
        } catch (error) {
          console.log(`🙄🙄 Something went wrong in ${tablePredictors}`);
        }
        break;

      case tableOnboardings:

        try {
          await deleteTable(tableOnboardings);
          // await createTable([tableOnboardings], firestore);
        } catch (error) {
          console.log(`🙄🙄 Something went wrong in ${tableOnboardings}`);
        }

        break;

      case tableUsers:

        try {
          await deleteTable(tableUsers);
          await createTable([tableUsers], firestore);
        } catch (error) {
          console.log(`🙄🙄 Something went wrong in ${tableUsers}`);
        }

        break;

      default:
        break;
    }
  });
};

//Deletes the table...
async function deleteTable(tableName) {
  let data = {
    datasetName: datasetName,
    collectionName: tableName
  };
  await helpers.deleteBQTables(data);
}

//Creates the table....
async function createTable(collectionName, firestore) {
  let dataToBeCreated = {
    datasetName: datasetName,
    collectionName: collectionName
  };

  await helpers.createBQTables(dataToBeCreated, firestore);

  helpers.batching(dataToBeCreated, collectionName[0], firestore);
}
