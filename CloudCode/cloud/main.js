
var moment = require('cloud/libs/moment');

// Parse App Id used to identify production environment
var PRODUCTION_APP_ID = "syVaVI0Ny6iQzfySxvDzkxvfJTY9MfyxcadfoHiK";

// Errors
var UNAUTHENTICATED_USER_ERROR = "User must be authenticated";

// Transactions
var SHIPPING_RATE = 15.0;
var MINIMUM_PAID_DOLLARS = 0.5; // Stripe's minimum is $0.50
var TRANSACTION_PERCENTAGE_FEE = 0.1;

// Config
var RESERVATION_AUTOCANCEL_SECONDS = 60;

// Make sure all installations point to the current user
Parse.Cloud.beforeSave(Parse.Installation, function(request, response) {
  Parse.Cloud.useMasterKey();
  request.object.set('user', request.user);
  response.success();
});
 
Parse.Cloud.beforeSave('Photo', function(request, response) {
  var currentUser = request.user;
  var objectUser = request.object.get('user');
  
  // Allow saving to owners and when using master key (to set as sold)
  if(!request.master && (!currentUser || !objectUser)) {
    response.error('A Photo should have a valid user.');
  } else if (request.master || (currentUser.id === objectUser.id)) {
    response.success();
  } else {
    response.error('Cannot set user on Photo to a user other than the current user.');
  }
});
 
Parse.Cloud.beforeSave('Activity', function(request, response) {
  var currentUser = request.user;
  var objectUser = request.object.get('fromUser');
 
  if(!currentUser || !objectUser) {
    response.error('An Activity should have a valid fromUser.');
  } else if (currentUser.id === objectUser.id) {
    response.success();
  } else {
    response.error('Cannot set fromUser on Activity to a user other than the current user.');
  }
});
 
Parse.Cloud.afterSave('Activity', function(request) {
  // Only send push notifications for new activities
  if (request.object.existed()) {
    return;
  }
 
  var toUser = request.object.get("toUser");
  if (!toUser) {
    throw "Undefined toUser. Skipping push for Activity " + request.object.get('type') + " : " + request.object.id;
    return;
  }
 
  if (request.object.get("type") === "comment") {
    // Send comment push
 
    var message = "";
    if (request.user.get('displayName')) {
      message = request.user.get('displayName') + ': ' + request.object.get('content').trim();
    } else {
      message = "Someone commented on your photo.";
    }
 
    // Trim our message to 100 characters.
    if (message.length > 100) {
      message = message.substring(0, 99);
    }
 
    var query = new Parse.Query(Parse.Installation);
    query.equalTo('user', toUser);
 
    Parse.Push.send({
      where: query, // Set our Installation query.
      data: {
        alert: message, // Set our alert message.
        badge: 'Increment', // Increment the target device's badge count.
        // The following keys help Anypic load the correct photo in response to this push notification.
        p: 'a', // Payload Type: Activity
        t: 'c', // Activity Type: Comment
        fu: request.object.get('fromUser').id, // From User
        pid: request.object.id // Photo Id
      }
    }, {
      success: function() {
        // Push was successful
        console.log('Successful push.');
      },
      error: function(error) {
        throw "Push Error " + error.code + " : " + error.message;
      }
    });
  } else if (request.object.get("type") === "like") {
    // Send like push
     
    var message = "";
    if (request.user.get('displayName')) {
      message = request.user.get('displayName') + ' likes your photo.';
    } else {
      message = 'Someone likes your photo.';
    }
 
    // Trim our message to 100 characters.
    if (message.length > 100) {
      message = message.substring(0, 99);
    }
 
    var query = new Parse.Query(Parse.Installation);
    query.equalTo('user', toUser);
 
    Parse.Push.send({
      where: query, // Set our Installation query.
      data: {
        alert: message, // Set our alert message.
        // The following keys help Anypic load the correct photo in response to this push notification.
        p: 'a', // Payload Type: Activity
        t: 'l', // Activity Type: Like
        fu: request.object.get('fromUser').id, // From User
        pid: request.object.id // Photo Id
      }
    }, {
      success: function() {
        // Push was successful
        console.log('Successful push.');
      },
      error: function(error) {
        throw "Push Error " + error.code + " : " + error.message;
      }
    });
  } else if (request.object.get("type") === "follow") {
    // Send following push
    var message = "";
    if (request.user.get('displayName')) {
      message = request.user.get('displayName') + ' is now following you.';
    } else {
      message = "You have a new follower.";
    }
 
    // Trim our message to 100 characters.
    if (message.length > 100) {
      message = message.substring(0, 99);
    }
 
    var query = new Parse.Query(Parse.Installation);
    query.equalTo('user', toUser);
 
    Parse.Push.send({
      where: query, // Set our Installation query.
      data: {
        alert: message, // Set our alert message.
        // The following keys help Anypic load the correct photo in response to this push notification.
        p: 'a', // Payload Type: Activity
        t: 'f', // Activity Type: Follow
        fu: request.object.get('fromUser').id // From User
      }
    }, {
      success: function() {
        // Push was successful
        console.log('Successful push.');
      },
      error: function(error) {
        throw "Push Error " + error.code + " : " + error.message;
      }
    });
  } else if (request.object.get("type") === "message") {
    // Send message push
     
    var message = "";
    if (request.user.get('displayName')) {
      message = request.user.get('displayName') + ' sent you a message.';
    } else {
      message = 'Someone sent you a message.';
    }
 
    // Trim our message to 100 characters.
    if (message.length > 100) {
      message = message.substring(0, 99);
    }
 
    var query = new Parse.Query(Parse.Installation);
    query.equalTo('user', toUser);
 
    Parse.Push.send({
      where: query, // Set our Installation query.
      data: {
        alert: message, // Set our alert message.
        // The following keys help Anypic load the correct photo in response to this push notification.
        p: 'a', // Payload Type: Activity
        t: 'm', // Activity Type: Like
        fu: request.object.get('fromUser').id, // From User
        pid: request.object.get('conversation').id // Photo Id
      }
    }, {
      success: function() {
        // Push was successful
        console.log('Successful push.');
      },
      error: function(error) {
        throw "Push Error " + error.code + " : " + error.message;
      }
    });
  } else if (request.object.get("type") === "sale") {
    var activity = request.object;
    var fromUser = activity.get('fromUser');
    var toUser = activity.get('toUser');
    var soldPhoto = activity.get('photo');

    // Send message push
    var message = '';

    if (fromUser.get('displayName')) {
      message = fromUser.get('displayName') + ' bought your item ';
    } else {
      message = 'Someone bought your item ';
    }

    return soldPhoto.fetch().then(function(soldPhoto) {
      message += soldPhoto.get('description');
   
      var query = new Parse.Query(Parse.Installation);
      query.equalTo('user', toUser);
   
      return Parse.Push.send({
        where: query, // Set our Installation query.
        data: {
          alert: message, // Set our alert message.
          // The following keys help Anypic load the correct photo in response to this push notification.
          p: 'a', // Payload Type: Activity
          t: 's', // Activity Type: Sale
          fu: fromUser.id, // From User
          pid: soldPhoto.id // Photo Id
        }
      });
    }, function(error) {
      console.error('Could not process sale activity: ' + error.message);
    });
  }
});

Parse.Cloud.beforeSave('Address', function(request, response) {
  var requestUser = request.user
  var addressObject = request.object;
 
  if(!requestUser) {
    response.error(UNAUTHENTICATED_USER_ERROR);
    return;
  }

  addressObject.set("user", requestUser);
  addressObject.setACL(new Parse.ACL(requestUser));

  response.success();
});

Parse.Cloud.beforeSave('Card', function(request, response) {
  var requestUser = request.user
  var cardObject = request.object;
 
  if(!requestUser) {
    response.error(UNAUTHENTICATED_USER_ERROR);
    return;
  }

  cardObject.set("user", requestUser);
  cardObject.setACL(new Parse.ACL(requestUser));

  response.success();
});

Parse.Cloud.beforeSave('Credits', function(request, response) {
  var credits = request.object;
  
  // Always keep only two decimal digits (truncate)
  var truncatedBalance = credits.get("balance");
  truncatedBalance = Math.floor(truncatedBalance * 100) / 100;

  if (truncatedBalance < 0) {
    response.error("Negative balance not allowed in user credits");
    return;
  }

  credits.set("balance", truncatedBalance);

  response.success();
});

/**
* Below are custom cloudcode function definitions for Relaced.
*/ 

var Stripe = require('stripe');
var stripeAPIKey = 'sk_test_zyRCOSdPFpmErs9ajcCXNOJQ';

// Use production Stripe's key in production app
if(Parse.applicationId === PRODUCTION_APP_ID) {
    stripeAPIKey = 'sk_live_O8ZCXNhZjaVn2KljRMbkd8ZO';
}

Stripe.initialize(stripeAPIKey);

Parse.Cloud.define("createCustomer", function(request, response) {
  var requestUser = request.user;
  var token = request.params.token;

  if (!requestUser) {
    response.error(UNAUTHENTICATED_USER_ERROR);
    return;
  }

  if (!token) {
    response.error('Card token not specified');
    return;
  }

  Stripe.Customers.create({
    card: token
  }).then(function(customer) {
    response.success(customer.id);
  }, function(error) {
    response.error("Could not create Stripe customer: " + error.message); 
  })
});

Parse.Cloud.define('refillBalance', function(request, response) {
  Parse.Cloud.useMasterKey();

  var currentUser, transaction;
  var preChargeErrorMsg = 'A server-side error occurred with your transaction. Your account was not charged.';
  var postChargeErrorMsg = 'There was a fatal error processing your Relaced balance refill. Please contact Relaced at your earliest convenience.';

  //Lets find the current user involved in this transaction first
  Parse.Promise.as().then(function() {
    var userQuery = new Parse.Query('_User');
    userQuery.equalTo('username', request.params.username);

    // Find the results. We handle any errors here so our
    // handlers don't conflict when the error propagates.
    return userQuery.first().then(null, function(error) {
      console.log('An error occurred finding information for user with username "' + request.params.username + '": ' + error);
      return Parse.Promise.error(preChargeErrorMsg);
    });

  }).then(function(user) {

    if (!user) {
      console.log('Unable to find information for user with username "' + request.params.username + '.');
      return Parse.Promise.error(preChargeErrorMsg);
    }

    currentUser = user;

    transaction = new Parse.Object('Transaction');
    transaction.set('user', user);
    transaction.set('amount', request.params.amount);
    transaction.set('paymentType', request.params.paymentType);
    transaction.set('successful', false);

    return transaction.save().then(null, function(error) {
      console.log('Creation of transaction object failed: ' + error);
      return Parse.Promise.error(preChargeErrorMsg);
    });

  }).then(function() {
    // Now we can charge the credit card using Stripe and the credit card token.
    return Stripe.Charges.create({
      amount: parseInt(request.params.amount * 100), // express dollars in cents 
      currency: 'usd',
      source: request.params.token
    }).then(null, function(error) {
      console.log('Charging with stripe failed: ' + error.message);
      return Parse.Promise.error(preChargeErrorMsg);
    });

  }).then(function(purchase) {

    // Credit card charged! Now we save the ID of the purchase on our
    // order and mark it as 'charged'.
    transaction.set('stripePaymentId', purchase.id);
    transaction.set('charged', true);

    return transaction.save().then(null, function(error) {
      console.log('An error occurred saving transaction information to the database: ' + error);
      return Parse.Promise.error(postChargeErrorMsg);
    });

  }).then(function() {
    //The payment was successful, so credit the user's account.
    var currentUserCreditsQuery = new Parse.Query('Credits');
    currentUserCreditsQuery.equalTo('user', currentUser);
    
    return currentUserCreditsQuery.first().then(null, function(error) {
      console.log('An error occurred finding credits information for user with username "' + request.params.username + '": ' + error);
      return Parse.Promise.error(postChargeErrorMsg);
    });

  }).then(function(credits) {
    oldBalance = credits.get('balance');
    credits.increment('balance', request.params.amount);

    return credits.save().then(null, function(error) {
      console.log("An error occurred saving the user's balance information to the database: " + error);
      return Parse.Promise.error(postChargeErrorMsg);
    });

  }).then(function() {
        var body = "Your Relaced balance was successfully updated.\n" +
               "Original Balance: $" + oldBalance + ".\n" +
               "Refill Amount: $" + request.params.amount + ".\n" +
               "New Balance: $" + (oldBalance + request.params.amount) + ".\n" +
               "Let us know if you had any issues or concerns!\n\n" +
               "Thank you,\n" +
               "The Relaced Team";

    // Send the email.
    return Mailgun.sendEmail({
      to: request.params.username,
      from: 'support@getrelaced.com',
      subject: 'Your Relaced Refill was successful!',
      text: body
    }).then(null, function(error) {
      //If we couldn't send the email, log this issue, but still continue on with the Promise chain
      console.log("Unable to email user '" + request.params.username + "': " + error);
      return Parse.Promise.as();
    });
    
  }).then(function() {
    //The entire transaction was generally successful.  Mark the transaction as such
    transaction.set('successful', true);

    return transaction.save().then(function() {
      return Parse.Promise.as('successful');
    }, function(error) {
      console.log('Could not mark transaction as successful: ' + error);
      return Parse.Promise.as('successful_but_indicator_not_saved');
    });

  }).then(function(result) {
    console.log('Finished transaction successfully.');
    response.success(result); 
  }, function(error) {
    console.log('An error occurred with the transaction: ' + error);
    response.error(error);
  });
});

Parse.Cloud.define('buyPhoto', function(request, response) {
  var requestUser = request.user;

  var photoId = request.params.photoId;
  var token = request.params.token; // Optional if customer provided
  var customer = request.params.customer; // Optional if token provided
  var paymentType = request.params.paymentType;
  var shippingAddress = request.params.shippingAddress;
  var calculatedCreditsDeducted = request.params.calculatedCreditsDeducted;

  if (!requestUser) {
    response.error(UNAUTHENTICATED_USER_ERROR);
    return;
  }

  if (!photoId) {
    response.error('Photo not specified');
    return;
  }

  if (!token && !customer) {
    response.error('Missing token');
    return;
  }

  if (!shippingAddress || (shippingAddress.length == 0)) {
    response.error('Missing shipping address');
    return;
  }

  if (calculatedCreditsDeducted == undefined) {
    response.error('Missing calculated credits deducted');
    return;
  }

  var photoToBuy;
  var sellerUser;
  var sellerCredits;
  var userCredits;
  var transaction;
  var totalAmount = 0;
  var finalPrice = 0;
  var transactionFee = 0;
  var sellerCreditsAdded = 0;

  // Fetch photo
  var photoQuery = new Parse.Query('Photo');

  return photoQuery.get(photoId).then(function(photo) {
    photoToBuy = photo;
    sellerUser = photoToBuy.get('user');

    if (!photoToBuy) {
      return Parse.Promise.error({
        message: 'Specified photo does not exist'
      });
    }

    if (photoToBuy.get('isSold') == "1") {
      return Parse.Promise.error({
        message: 'Specified photo already sold'
      });
    }

    var reservationUser = photoToBuy.get('reservationUser');

    if (reservationUser && (reservationUser.id != requestUser.id)) {
      return Parse.Promise.error({
        message: 'Another user is trying to buy this item'
      });
    }

    return Parse.Promise.when(
      getOrCreateUserCredits(sellerUser),
      getOrCreateUserCredits(requestUser)
    ).then(null, function(errors) {
      return Parse.Promise.error(getFirstError(errors));
    });
  }).then(function(sellerCreditsResult, buyerCreditsResult) {

    if (!sellerCreditsResult || !buyerCreditsResult ) {
      return Parse.Promise.error({
        message: 'Could not retrieve buyer and seller credits'
      });
    }

    buyerCredits = buyerCreditsResult;
    sellerCredits = sellerCreditsResult;

    // Calculate total amount
    var subtotalPrice = photoToBuy.get('price');
    var shippingRate = SHIPPING_RATE;
    finalPrice = subtotalPrice + shippingRate;

    // Calculate transaction fee
    transactionFee = subtotalPrice * TRANSACTION_PERCENTAGE_FEE; 
    transactionFee = Math.ceil(transactionFee * 100) / 100; // Round up transaction fee to two decimal digits

    // Check calculated credits to deduct
    var userBalance = buyerCredits.get('balance');
    var newUserBalance;

    // Check calculatedCreditsDeducted conditions
    // Using calculatedCreditsDeducted ensures backend charges match payment summary shown in-app
    if (calculatedCreditsDeducted > userBalance) {
      return Parse.Promise.error({
        message: 'User credits decreased while processing transaction, please retry the purchase'
      });
    }

    if (calculatedCreditsDeducted > (finalPrice - MINIMUM_PAID_DOLLARS)) {
      return Parse.Promise.error({
        message: 'Minimum payable amount not complied'
      });
    }

    // Calculate final amounts    
    newUserBalance = (userBalance - calculatedCreditsDeducted).toFixed(2);
    totalAmount = finalPrice - calculatedCreditsDeducted;
    sellerCreditsAdded = finalPrice - transactionFee - SHIPPING_RATE;

    console.error("calculatedCreditsDeducted " + calculatedCreditsDeducted);
    console.error("balance " + userBalance);
    console.error("newUserBalance " + newUserBalance);

    // Create transaction
    transaction = new Parse.Object('Transaction');
    transaction.set('user', requestUser);
    transaction.set('photo', photoToBuy);
    transaction.set('creditsDeducted', calculatedCreditsDeducted);
    transaction.set('photoPrice', subtotalPrice);
    transaction.set('transactionFee', transactionFee);
    transaction.set('shippingRate', shippingRate);
    transaction.set('amount', totalAmount);
    transaction.set('paymentType', request.params.paymentType);
    transaction.set('successful', false);
    transaction.set('shippingAddress', shippingAddress);
    transaction.set('sellerCreditsAdded', sellerCreditsAdded);

    return transaction.save();
  }).then(function() {
    if (totalAmount < MINIMUM_PAID_DOLLARS) {
      // Stripe does not allow to charge $0
      return Parse.Promise.error({
        message: "amount to be paid is less than allowed"
      });
    }

    if (token) {
      // Charge the card
      return Stripe.Charges.create({
        amount: totalAmount * 100, // dollars in cents 
        currency: 'usd',
        source: token
      });
    } 
    else {
      // Charge the customer
      return Stripe.Charges.create({
        amount: totalAmount * 100, // dollars in cents 
        currency: 'usd',
        customer: customer
      });
    }
  }).then(function(purchase) {
    // Save purchase ID and mark as 'charged'
    transaction.set('stripePaymentId', purchase.id);
    transaction.set('charged', true);

    return transaction.save();
  }).then(function() {
    // Set item as sold
    photoToBuy.set('isSold', '1');

    return photoToBuy.save(null, {
      useMasterKey: true
    });
  }).then(function() {
    // Update credit balance
    buyerCredits.increment('balance', -calculatedCreditsDeducted);
    sellerCredits.increment('balance', sellerCreditsAdded);

    return Parse.Promise.when(
      buyerCredits.save(null, { useMasterKey: true }),
      sellerCredits.save(null, { useMasterKey: true })
    ).then(null, function(errors) {
      return Parse.Promise.error(getFirstError(errors));
    });
  }).then(function() {
    // Notify seller
    var saleActivity = new Parse.Object('Activity');
    saleActivity.set('type', 'sale');
    saleActivity.set('fromUser', requestUser);
    saleActivity.set('toUser', sellerUser);
    saleActivity.set('photo', photoToBuy);
    saleActivity.set('transaction', transaction);

    var activityACL = new Parse.ACL(requestUser);
    activityACL.setReadAccess(sellerUser, true);
    activityACL.setWriteAccess(sellerUser, true);
    saleActivity.setACL(activityACL);

    return saleActivity.save();
  }).then(function() {
    // The entire transaction was generally successful
    transaction.set('successful', true);

    return transaction.save();
  }).then(function() {
    response.success('Success');
  }, function(error) {
    response.error("Could not complete purchase: " + error.message);
  });
});

Parse.Cloud.define('performPhotoReservation', function(request, response) {
  var requestUser = request.user;

  var photoId = request.params.photoId;

  if (!requestUser) {
    response.error(UNAUTHENTICATED_USER_ERROR);
    return;
  }

  if (!photoId) {
    return Parse.Promise.error({
      message: 'Photo not Specified'
    });
  }

  // Fetch photo
  var photoQuery = new Parse.Query('Photo');

  return photoQuery.get(photoId).then(function(photoToReserve) {
    if (!photoToReserve) {
      return Parse.Promise.error({
        message: 'Specified photo does not exist'
      });
    }

    if (photoToReserve.get('isSold') == "1") {
      return Parse.Promise.error({
        message: 'Specified photo already sold'
      });
    }

    // Check if item already reserved by current user
    var reservationUser = photoToReserve.get('reservationUser');

    if (reservationUser && (reservationUser.id == requestUser.id)) {
      return Parse.Promise.as();
    }

    // Check if reservation should be auto canceled
    var reservationDate = photoToReserve.get('reservationDate');

    if (reservationDate) {
      var autocancelDateMoment = moment(reservationDate);
      autocancelDateMoment.add(RESERVATION_AUTOCANCEL_SECONDS, 's');

      if (autocancelDateMoment.isAfter(moment())) {
        return Parse.Promise.error({
          message: 'Other user is trying to buy this item'
        });
      }
    }
    
    // Reserve photo
    photoToReserve.set('reservationDate', moment().toDate());
    photoToReserve.set('reservationUser', requestUser);

    return photoToReserve.save(null, {
      useMasterKey: true
    });
  }).then(function() {
    response.success('Success');
  }, function(error) {
    response.error('Could not perform reservation: ' + error.message);
  });
});

Parse.Cloud.define('cancelPhotoReservation', function(request, response) {
  var requestUser = request.user;

  var photoId = request.params.photoId;

  if (!requestUser) {
    response.error(UNAUTHENTICATED_USER_ERROR);
    return;
  }

  if (!photoId) {
    return Parse.Promise.error({
      message: 'Photo not Specified'
    });
  }

  // Fetch photo
  var photoQuery = new Parse.Query('Photo');
  photoQuery.equalTo('reservationUser', requestUser);

  return photoQuery.get(photoId).then(function(reservedPhoto) {
    if (reservedPhoto) {
      // Cancel reservation
      reservedPhoto.unset('reservationDate');
      reservedPhoto.unset('reservationUser');
      
      return reservedPhoto.save(null, {
        useMasterKey: true
      });
    }

    return Parse.Promise.as(); 
  }).then(function() {
    response.success('Success');
  }, function(error) {
    response.error('Could not cancel reservation');
  });
});

// Helpers

function getFirstError(errors) {
  for(var i = 0; i < errors.length; i++) {
    var error = errors[i];

    if(error) {
      return error;
    }
  }

  return {
    message: "Error not found"
  };
}

function getOrCreateUserCredits(creditsUser) {
  var creditsQuery = new Parse.Query('Credits');
  creditsQuery.equalTo('user', creditsUser)
  
  return creditsQuery.first().then(function(credits) {
    if (!credits) {
      var credits = new Parse.Object('Credits');
      credits.set('user', creditsUser);
      credits.set('balance', 0);

      var creditsACL = new Parse.ACL(creditsUser);
      creditsACL.setPublicReadAccess(true);
      credits.setACL(creditsACL);

      return credits.save();
    } 
    else {
      return Parse.Promise.as(credits);
    }
  });
}
