const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const algoliasearch = require('algoliasearch');
const client = algoliasearch('0D2Q7L4DCF', '9af8c0a03e3459c97d6373ed9afc003e');
const index = client.initIndex('profiles');

exports.indexProfile = functions.firestore
  .document('profiles/{profileId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();

    // Check if the "avatars" field exists and is not empty

    // Extract the first element's "imageURL" from the "avatars" array
 
    // Create the transformed data structure
    index.saveObject( {
      objectID: snap.id, // Specify the Algolia objectID (unique identifier)
      avatarImageURL: data.avatars[0].imageURL, // Use the first avatar's "imageURL"
      // Add any other fields or transformations you need
	  ...data
    });


    // Add the transformed data to Algolia
    // await index.saveObject(transformedData);
  });

const transformProfile = (payload) => {
  return {
    "avatarImageURL": payload["avatars"][0].imageURL,
    "username": payload["username"],
    "fullName": payload["fullName"],
    "privacy": payload["privacy"],
    "type": payload["type"],
    ...payload,
  };
};

exports.sendNotification = functions.firestore
  .document('inbox/{inboxId}')
  .onWrite((change, context) => {
    // Check if the document is created or modified
    if (!change.before.exists) {
      // Document is created
      const data = change.after.data();
      const members = data.members || [];
      const message = data.recentMessage;

      members.forEach((member) => {
        const topic = member.id + 'direct';
        
        const payload = {
          notification: {
            title: recentMessage.timestamp.profile.fullName,
            body: recentMessage.text,
          },
        };

        return admin.messaging().sendToTopic(topic, payload);
      });
    } else {
      // Document is modified (you can handle modifications as needed)
      // For example, you may want to check specific fields before triggering a notification
    }

    return null;
  });


exports.transformProfileForSearch = functions.https.onCall((payload) => {
  const transformedData = transformProfile(payload);
  return transformedData;
});