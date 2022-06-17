import * as functions from "firebase-functions";
import { addMatch, getPlayer, updatePlayer } from "./helpers/firebase.helpers";
import { Sport } from "./types/Sport";
import EloRating from "elo-rating";
import { Match } from "./types/Match";
import { setEmptyPlayerStats } from "./helpers/player.helpers";

const BAD_REQUEST = 400;
const METHOD_NOT_ALLOWED = 405;

const initialScore = 1200;

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
export const winMatch = functions.https.onRequest(async (request, response) => {
  functions.logger.info("Hello logs!", { structuredData: true });

  const isPost = request.method === "POST";
  if (!isPost) {
    response.sendStatus(METHOD_NOT_ALLOWED);
    return;
  }

  const {
    winnerId,
    loserId,
    sport,
  }: { winnerId: string; loserId: string; sport: Sport } = request.body;

  const winner = await getPlayer(winnerId);

  const loser = await getPlayer(loserId);

  console.log({ winnerId, loserId, sport, body: request.body, winner, loser });

  if (!winner || !loser) {
    response.sendStatus(BAD_REQUEST);
    return;
  }

  setEmptyPlayerStats(winner, initialScore);
  setEmptyPlayerStats(loser, initialScore);

  if (sport === Sport.Unknown || sport > 1) {
    response.sendStatus(BAD_REQUEST);
    return;
  }

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
    date: new Date().toISOString(),
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

  response.send(match);
});
