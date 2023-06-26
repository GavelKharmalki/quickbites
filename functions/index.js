/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

//const {onRequest} = require("firebase-functions/v2/https");
//const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require("firebase-functions");
const stripe = require("stripe")("sk_test_51N6qqISGivbEzeqlxJ0fydu8OW5esdQYmrwGjMdSgtVlxfcLXnUXJNF7SBmj542ZYzGFfzlFvrRCwwFIseoaZqNb00Pu2Wdyvf");

exports.stripePaymentIntentRequest = functions.https.onRequest(async(req,res)=>{
try{
    let customerId;

    //Gets the customer who's email id matches the one sent by the client
    const customerList = await stripe.customers.list({
        email: req.body.email,
        limit: 1
    });

    //Checks if the customer exists, if not createas a new customer
    if (customerList.data.length !== 0){
        customerId = customerList.data[0].id;
    }
    else{
        const customer = await stripe.customers.create({
            email: req.body.email
        });
        customerId = customer.data.id;
    }
    console.log('Customer ID:', customerId);
    //Creates a temporary secret key linked with the customer
    const ephemeralKey = await stripe.ephemeralKeys.create(
        {customer: customerId},
        {apiVersion: '2022-11-15'}
    );

    //Creates a new payment intent with amount passed in from the client
    const paymentIntent = await stripe.paymentIntents.create({
        amount: parseInt(req.body.amount),
        currency: 'INR',
        customer: customerId,
    })

    res.status(200).send({
        paymentIntent: paymentIntent.client_secret,
        ephemeralKey: ephemeralKey.secret,
        customer: customerId,
        success: true,
    })
    }catch (error){
    res.status(404).send({success: false,error: error.message})
}
});

