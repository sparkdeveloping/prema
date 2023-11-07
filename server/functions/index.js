const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const algolia = require('algoliasearch');
const client = algolia('0D2Q7L4DCF', '9af8c0a03e3459c97d6373ed9afc003e');
const index = client.initIndex('profiles');

exports.indexProfile = functions.firestore
  .document('profiles/{profileId}')
  .onCreate((snap, context) => {
    const data = snap.data();
    
    // Check if the "avatars" array exists and is not empty
    if (data.avatars && data.avatars.length > 0) {
      const firstAvatar = data.avatars[0];
      const imageURL = firstAvatar.imageURL;

      // Add the profile to Algolia with the first avatar's imageURL
      return index.addObject({
        objectID: context.params.profileId,
        ...data,
        avatarImageURL: imageURL // You can add this field for Algolia indexing
      });
    } else {
      // If "avatars" array is empty or missing, add the profile without an avatarImageURL field
      return index.addObject({
        objectID: context.params.profileId,
        ...data
      });
    }
  });


