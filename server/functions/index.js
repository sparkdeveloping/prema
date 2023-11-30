const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendDirectNotifications = functions.firestore
  .document("inbox/{inboxId}")
  .onWrite((snapshot, context) => {
    // Notification details.
    const data = snapshot.after.data();
    console.log("sending ", data);

    const accepts = data.accepts | [];
    const requests = data.requests | [];
    // Get the list of device tokens.
    console.log("accepts ", data.accepts);
    console.log("requests ", data.requests);
    console.log("profile ", data.recentMessage.timestamp.profile);
    console.log("profile 2 ", data.recentMessage.timestamp.profile.fullName);

    var message = "New Message";

    if (data.recentMessage.text) {
      message = data.recentMessage.text;
    }
    if (data.accepts.length > 0) {
      data.accepts.forEach((recipient) => {
        if (recipient != data.recentMessage.timestamp.profile.id) {
          const payload = {
            notification: {
              title: data.recentMessage.timestamp.profile.fullName,
              body: message,
              mutable_content: "true",
            },
            data: {
              mutable_content: "true",
              inboxID: data.id,
            },
          };
          console.log("sending to topic", `${recipient}direct`);
          admin.messaging().sendToTopic(`${recipient}direct`, payload);
        }
      });
    }
    if (data.requests.length > 0) {
      data.requests.forEach((recipient) => {
        const payload = {
          notification: {
            title: data.recentMessage.timestamp.profile.fullName,
            body: "Wants to direct message you",
            mutable_content: "true",
          },
          data: {
            mutable_content: "true",
            inboxID: data.id,
          },
        };
        console.log("sending request ", `${recipient}direct`);
        admin.messaging().sendToTopic(`${recipient}direct`, payload);
      });
    }
  });
