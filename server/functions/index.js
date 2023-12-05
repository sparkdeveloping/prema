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

    const message = data.recentMessage;
    const type = message.type;
    var messageText = "New Message";
    console.log(`this is the print 0}`);

    if (type == "text") {
      console.log(`this is the print 1: ${message.type}`);
      if (message.text) {
        messageText = message.text;
        console.log(`this is the print 2: ${message}`);
      }
    }
    if (type == "image") {
      messageText = "Image📸";
    }
    if (type == "video") {
      messageText = "Video🎥";
    }
    if (type == "sticker") {
      messageText = "Sticker🌞";
    }

    if (data.expiry) {
      messageText = "Sensitive Message🔒";
    }

    if (data.destruction) {
      messageText = "Destructive Message💣";
    }

    messageText =
      data.members.length > 2
        ? `@${message.timestamp.profile.username} sent a ${messageText}`
        : "";

    if (data.accepts.length > 0) {
      data.accepts.forEach((recipient) => {
        if (recipient != message.timestamp.profile.id) {
          const payload = {
            notification: {
              title: message.timestamp.profile.fullName,
              body: messageText,
              mutable_content: "true",
            },
            data: {
              mutable_content: "true",
              inboxID: data.id,
            },
          };
          console.log(
            "sending to topic",
            `${recipient}direct the message: ${messageText}`
          );
          `${recipient}direct the message: ${messageText} of type: ${type}`;
          admin.messaging().sendToTopic(`${recipient}direct`, payload);
        }
      });
    }
    if (data.requests.length > 0) {
      data.requests.forEach((recipient) => {
        const payload = {
          notification: {
            title: message.timestamp.profile.fullName,
            body:
              data.members.length > 2
                ? "Added you to a new group👥"
                : "Wants to direct message you",
            mutable_content: "true",
          },
          data: {
            mutable_content: "true",
            inboxID: data.id,
          },
        };
        console.log(
          "sending to topic",
          `${recipient}direct the message: ${messageText} of type: ${type}`
        );
        admin.messaging().sendToTopic(`${recipient}direct`, payload);
      });
    }
  });
