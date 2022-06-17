import * as functions from "firebase-functions";
import { getPlayer } from "./helpers/firebase.helpers";
import { Sport } from "./types/Sport";
import { calculate } from "elo-rating";
import { Match } from "./types/Match";

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

  if (sport === Sport.Unknown) {
    response.sendStatus(BAD_REQUEST);
    return;
  }

  const oldWinnerScore =
    (sport === Sport.Foosball
      ? winner.foosballStats?.score
      : winner.tableTennisStats?.score) ?? initialScore;

  const oldLoserScore =
    (sport === Sport.Foosball
      ? loser.foosballStats?.score
      : loser.tableTennisStats?.score) ?? initialScore;

  const { playerRating: newWinnerScore, opponentRating: newLoserScore } =
    calculate(oldWinnerScore, oldLoserScore);

  console.log({ newWinnerScore, newLoserScore });

  const match: Match = {
    date: new Date().toISOString(),
    sport,
    winner,
    loser,
    winnerDelta: newWinnerScore - oldWinnerScore,
    loserDelta: newLoserScore - oldLoserScore,
  };

  // TODO: Store match in db
  // TODO: Store updated winner score
  // TODO: Store updated loser score

  response.send(match);
});
