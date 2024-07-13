const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendDangerAlert = functions.https.onCall((data, context) => {
  const message = {
    notification: {
      title: data.title,
      body: data.body,
    },
    topic: "alerts",
  };

  return admin
      .messaging()
      .send(message)
      .then((response) => {
        console.log("Successfully sent message:", response);
        return {success: true};
      } )
      .catch((error) => {
        console.log("Error sending message:", error);
        return {success: false};
      });
});
