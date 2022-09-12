import EloRating from "elo-rating";
import * as firebase from "firebase-admin";
import * as functions from "firebase-functions";
import HttpStatus from "http-status-enum";
import { initialScore, tietoevryCreateTeamId } from "./constants";
import { addMatch } from "./firebase/match";
import { getPlayer, updatePlayer } from "./firebase/player";
import { storeSeason } from "./firebase/season";
import { getTeams } from "./firebase/team";
import { sendErrorStatus } from "./helpers/api.helpers";
import {
  getLeader,
  incrementTotalSeasonWins,
  resetScoreboards,
} from "./helpers/firebase.helpers";
import { setEmptyPlayerStats } from "./helpers/player.helpers";
import * as slackHelpers from "./helpers/slack.helpers";
import { getSportStats, sportNames } from "./helpers/sport.helpers";
import { validateWinMatchBody } from "./helpers/validation.helpers";
import { ErrorCodes } from "./types/ErrorCodes";
import { Match } from "./types/Match";
import { Season } from "./types/Season";
import { SlackCommandResponse } from "./types/SlackCommandResponse";
import { Sport } from "./types/Sport";
import { WinMatchBody } from "./types/WinMatchBody";

export const winMatch = functions.https.onRequest(
  async (request, response): Promise<void> => {
    functions.logger.info("Hello logs!", { structuredData: true });

    const isPost = request.method === "POST";
    if (!isPost) {
      sendErrorStatus(response, HttpStatus.METHOD_NOT_ALLOWED, [
        {
          errorCode: ErrorCodes.WinMatchMethodNotAllowed,
          message: `Method '${request.method}' is not allowed`,
        },
      ]);
      return;
    }

    const bodyErrors = validateWinMatchBody(request.body);
    if (bodyErrors) {
      sendErrorStatus(response, HttpStatus.BAD_REQUEST, bodyErrors);
    }

    const { winnerId, loserId, sport }: WinMatchBody = request.body;

    console.log({ body: request.body });

    const winner = await getPlayer(winnerId);
    const loser = await getPlayer(loserId);

    console.log({ winnerId, loserId, sport, winner, loser });

    if (!winner) {
      sendErrorStatus(response, HttpStatus.BAD_REQUEST, [
        {
          errorCode: ErrorCodes.WinnerNotFound,
          message: `Player with id '${winnerId} not found`,
        },
      ]);
      return;
    }

    if (!loser) {
      sendErrorStatus(response, HttpStatus.BAD_REQUEST, [
        {
          errorCode: ErrorCodes.LoserNotFound,
          message: `Player with id '${loserId} not found`,
        },
      ]);
      return;
    }

    setEmptyPlayerStats(winner);
    setEmptyPlayerStats(loser);

    const winnerStats = getSportStats(winner, sport);
    const loserStats = getSportStats(loser, sport);

    if (!winnerStats || !loserStats) {
      throw new Error(`Missing stats for sport ${sport}`);
    }

    const oldWinnerScore = winnerStats.score ?? initialScore;
    const oldLoserScore = loserStats.score ?? initialScore;

    const { playerRating: newWinnerScore, opponentRating: newLoserScore } =
      EloRating.calculate(oldWinnerScore, oldLoserScore);

    console.log({ newWinnerScore, newLoserScore });

    const match: Match = {
      date: new firebase.firestore.Timestamp(Math.floor(Date.now() / 1000), 0),
      sport,
      winner,
      loser,
      winnerDelta: newWinnerScore - oldWinnerScore,
      loserDelta: newLoserScore - oldLoserScore,
    };

    addMatch(match);

    winnerStats.matchesPlayed += 1;
    winnerStats.matchesWon += 1;
    winnerStats.score = newWinnerScore;

    loserStats.matchesPlayed += 1;
    loserStats.score = newLoserScore;

    updatePlayer(winner);
    updatePlayer(loser);

    console.log({ match });

    response.send(match);
  },
);

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

const isSport = (value: string | Sport): value is Sport =>
  typeof value !== "string";

const resetScoreboardsFunction = async () => {
  const sports = Object.values(Sport)
    .filter(isSport)
    .filter(sport => sport !== Sport.Unknown);

  const now = new Date();
  const seasonStartDate = new Date();
  seasonStartDate.setMonth(Math.abs((now.getMonth() - 1 + 12) % 12));

  const timestamp = new firebase.firestore.Timestamp(
    Math.floor(seasonStartDate.getTime() / 1000),
    0,
  );
  console.log("Timestamp:", timestamp);

  const seasonsWithWinners: Array<Season> = [];

<<<<<<< HEAD
  for (const sport of sports) {
    const seasonWinner = await getLeader(sport);
    if (!seasonWinner) {
      continue;
    }
=======
  const teams = await getTeams();

  if (seasonWinnerFoosball) {
    console.log("Foosball has season winner. Incrementing total season wins");
    await incrementTotalSeasonWins(seasonWinnerFoosball, Sport.Foosball);

    console.log("Storing foosball season");
    await storeSeason(seasonWinnerFoosball, Sport.Foosball, timestamp);

    seasonsWithWinners.push({
      winner: seasonWinnerFoosball,
      sport: Sport.Foosball,
      date: timestamp,
    });
  }
>>>>>>> fa9beb3 (feat: fetch all teams)

    console.log(`${sportNames[sport]} winner`, seasonWinner);
    await incrementTotalSeasonWins(seasonWinner, sport);

    console.log(`Storing ${sportNames[sport]} season`);
    await storeSeason(seasonWinner, sport, timestamp);

    seasonsWithWinners.push({
      winner: seasonWinner,
      sport,
      date: timestamp,
    });
  }

  console.log("Resetting score boards");
  await resetScoreboards(initialScore);

  await slackHelpers.postSeasonResults(seasonsWithWinners);
};

export const resetScoreboardsCron = functions
  .runWith({
    secrets: ["SLACK_TOKEN", "SLACK_CHANNEL"],
  })
  .pubsub.schedule("1 of month 00:00")
  .onRun(async () => {
    console.log("Resetting score boards");

    await resetScoreboardsFunction();

    console.log("Finished resetting score boards");
    return null;
  });
