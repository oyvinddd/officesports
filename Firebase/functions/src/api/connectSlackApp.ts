import * as functions from "firebase-functions";
import * as slackHelpers from "../helpers/slack.helpers";

export const connectSlackApp = functions
  .runWith({
    secrets: ["SLACK_CLIENT_ID", "SLACK_CLIENT_SECRET", "SLACK_TOKEN"],
  })
  .https.onRequest(async (request, response): Promise<void> => {
    const { originalUrl, path, params, body } = request;
    console.log({ originalUrl, path, params, body });

    let { code } = request.query;

    if (Array.isArray(code)) {
      code = code[0];
    }

    if (!code) {
      console.error("Missing 'code' query param");
      response.send("Missing 'code' query param");

      return;
    }

    const accessToken = await slackHelpers.authenticate(code.toString());

    response.send({
      originalUrl,
      path,
      params,
      body,
      accessToken,
      isSuccess: !!accessToken,
    });
  });
