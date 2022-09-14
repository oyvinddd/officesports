import EloRating from "elo-rating";
import * as firebase from "firebase-admin";
import * as functions from "firebase-functions";
import HttpStatus from "http-status-enum";
import { initialScore, testIds } from "../constants";
import { addMatch } from "../firebase/match";
import { getPlayer, updatePlayer } from "../firebase/player";
import { sendErrorStatus } from "../helpers/api.helpers";
import { setEmptyPlayerStats } from "../helpers/player.helpers";
import { getSportStats } from "../helpers/sport.helpers";
import { validateWinMatchBody } from "../helpers/validation.helpers";
import { ErrorCodes } from "../types/ErrorCodes";
import { Match } from "../types/Match";
import { WinMatchBody } from "../types/WinMatchBody";

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

    const sameTeam =
      (winner.teamId ?? winner.team.id) === (loser.teamId ?? loser.team.id);
    if (sameTeam) {
      match.teamId = winner.teamId ?? winner.team.id ?? undefined;
    }

    winnerStats.matchesPlayed += 1;
    winnerStats.matchesWon += 1;
    winnerStats.score = newWinnerScore;

    loserStats.matchesPlayed += 1;
    loserStats.score = newLoserScore;

    const isDebug = testIds.includes(loser.userId);
    if (!isDebug) {
      addMatch(match);
      updatePlayer(winner);
      updatePlayer(loser);
    }

    console.log({ match });

    response.send(match);
  },
);
