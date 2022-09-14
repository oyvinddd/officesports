import * as functions from "firebase-functions";
import { tietoevryCreateTeamId } from "../constants";
import { getLeader } from "../helpers/firebase.helpers";
import * as slackHelpers from "../helpers/slack.helpers";
import { SlackCommandResponse } from "../types/SlackCommandResponse";
import { Sport } from "../types/Sport";

// TODO: `slackGetLeader` is the endpoint for all `/os` commands. It should be renamed to reflect that.
export const slackGetLeader = functions
  .runWith({
    secrets: ["SLACK_TOKEN", "SLACK_CHANNEL"],
  })
  .https.onRequest(async (request, response) => {
    let { text } = request.body;

    console.log("Slack get leader", {
      query: JSON.stringify(request.query),
      params: JSON.stringify(request.params),
      body: request.body,
      headers: JSON.stringify(request.headers),
    });

    if (Array.isArray(text)) {
      text = text[0];
    }

    if (!text) {
      response.send("Missing text");
      return;
    }

    // `/os leader [sport]`
    // `/os` is the command, `leader [sport]` is the text
    const [subCommand, ...sportName] = text.toString().split(" ");
    const isLeaderCommand = subCommand.toLowerCase() === "leader";
    if (!isLeaderCommand) {
      const res: SlackCommandResponse = {
        response_type: "ephemeral",
        blocks: [
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: `'${subCommand}' is not a valid sub command. Valid sub commands are:
              - 'leader'`,
            },
          },
        ],
      };
      response.send(res);
      return;
    }

    const sport = sportName.join(" ").toLowerCase();
    if (sport === "foosball") {
      const leader = await getLeader(Sport.Foosball, tietoevryCreateTeamId);
      console.log("Foosball leader", { leader });
      const blocks = slackHelpers.formatLeaderText(Sport.Foosball, leader);

      const res: SlackCommandResponse = {
        response_type: "ephemeral",
        blocks,
      };
      response.send(res);

      return;
    } else if (
      ["table tennis", "table-tennis", "tabletennis"].includes(sport)
    ) {
      const leader = await getLeader(Sport.TableTennis);
      console.log("Table tennis leader", { leader });

      const blocks = slackHelpers.formatLeaderText(Sport.TableTennis, leader);

      const res: SlackCommandResponse = {
        response_type: "ephemeral",
        blocks,
      };
      response.send(res);

      return;
    } else if (["pool"].includes(sport)) {
      const leader = await getLeader(Sport.Pool);
      console.log("Pool leader", { leader });

      const blocks = slackHelpers.formatLeaderText(Sport.Pool, leader);

      const res: SlackCommandResponse = {
        response_type: "ephemeral",
        blocks,
      };
      response.send(res);

      return;
    } else if (sport === "") {
      const foosballLeader = await getLeader(Sport.Foosball);
      const tableTennisLeader = await getLeader(Sport.TableTennis);
      const poolLeader = await getLeader(Sport.Pool);

      console.log("All leaders", {
        foosballLeader,
        tableTennisLeader,
        poolLeader,
      });

      const foosballBlocks = slackHelpers.formatLeaderText(
        Sport.Foosball,
        foosballLeader,
      );
      const tableTennisBlocks = slackHelpers.formatLeaderText(
        Sport.TableTennis,
        tableTennisLeader,
      );
      const poolBlocks = slackHelpers.formatLeaderText(Sport.Pool, poolLeader);

      const res: SlackCommandResponse = {
        response_type: "ephemeral",
        blocks: [...foosballBlocks, ...tableTennisBlocks, ...poolBlocks],
      };
      response.send(res);
    }
  });
