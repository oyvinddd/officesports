import * as functions from "firebase-functions";

const METHOD_NOT_ALLOWED = 405;

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
export const winMatch = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", { structuredData: true });

  const isPost = request.method === "POST";
  if (!isPost) {
    response.sendStatus(METHOD_NOT_ALLOWED);
  }

  const { winnerId, loserId }: { winnerId: string; loserId: string } =
    request.body;
});
