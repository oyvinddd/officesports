import EloRating from "elo-rating";
import * as firebase from "firebase-admin";
import * as functions from "firebase-functions";
import HttpStatus from "http-status-enum";
import { initialScore } from "./constants";
import { sendErrorStatus } from "./helpers/api.helpers";
import {
  addMatch,
  getLeader,
  getPlayer,
  incrementTotalSeasonWins,
  resetScoreboard as resetScoreboards,
  storeSeason,
  updatePlayer,
} from "./helpers/firebase.helpers";
import { setEmptyPlayerStats } from "./helpers/player.helpers";
import { validateWinMatchBody } from "./helpers/validation.helpers";
import { ErrorCodes } from "./types/ErrorCodes";
import { Match } from "./types/Match";
import { Sport } from "./types/Sport";
import { WinMatchBody } from "./types/WinMatchBody";

export const winMatch = functions.https.onRequest(async (request, response) => {
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

  setEmptyPlayerStats(winner, initialScore);
  setEmptyPlayerStats(loser, initialScore);

  const isFoosball = sport === Sport.Foosball;
  const isTableTennis = sport === Sport.TableTennis;

  const oldWinnerScore =
    (isFoosball
      ? winner.foosballStats?.score
      : winner.tableTennisStats?.score) ?? initialScore;

  const oldLoserScore =
    (isFoosball ? loser.foosballStats?.score : loser.tableTennisStats?.score) ??
    initialScore;

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

  if (isFoosball) {
    if (!winner.foosballStats || !loser.foosballStats) {
      throw new Error("Missing foosball stats");
    }

    winner.foosballStats.matchesPlayed += 1;
    winner.foosballStats.score = newWinnerScore;

    loser.foosballStats.matchesPlayed += 1;
    loser.foosballStats.score = newLoserScore;
  }

  if (isTableTennis) {
    if (!winner.tableTennisStats || !loser.tableTennisStats) {
      throw new Error("Missing foosball stats");
    }

    winner.tableTennisStats.matchesPlayed += 1;
    winner.tableTennisStats.score = newWinnerScore;

    loser.tableTennisStats.matchesPlayed += 1;
    loser.tableTennisStats.score = newLoserScore;
  }

  updatePlayer(winner);
  updatePlayer(loser);

  console.log({ match });

  response.send(match);
});

const resetScoreboardsFunction = async () => {
  const seasonWinnerFoosball = await getLeader(Sport.Foosball);
  const seasonWinnerTableTennis = await getLeader(Sport.TableTennis);

  if (seasonWinnerFoosball) {
    incrementTotalSeasonWins(seasonWinnerFoosball, Sport.Foosball);
    storeSeason(seasonWinnerFoosball, Sport.Foosball);
  }

  if (seasonWinnerTableTennis) {
    incrementTotalSeasonWins(seasonWinnerTableTennis, Sport.TableTennis);
    storeSeason(seasonWinnerTableTennis, Sport.TableTennis);
  }

  resetScoreboards(initialScore);
};

export const resetScoreboardsCron = functions.pubsub
  .schedule("0 0 1 * *")
  .onRun(resetScoreboardsFunction);

// export const resetScoreboardsHttp = functions.https.onRequest(
//   resetScoreboardsFunction,
// );
