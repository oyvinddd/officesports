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
import { ErrorWithMessage } from "../types/ErrorWithMessage";
import { Match } from "../types/Match";
import { Player } from "../types/Player";
import { WinMatchBody } from "../types/WinMatchBody";

const isDefined = <T>(value: T | null | undefined): value is T => value != null;
const validateTeam = (player: Player): boolean =>
  player.team.id != null || player.teamId != null;

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

    const {
      winnerId,
      winnerIds: wIds,
      loserId,
      loserIds: lIds,
      sport,
    }: WinMatchBody = request.body;

    console.log({ body: request.body });

    const winnerIds = [...new Set([winnerId ?? wIds![0], ...(wIds ?? [])])];
    const loserIds = [...new Set([loserId ?? lIds![0], ...(lIds ?? [])])];

    const winners = await Promise.all(winnerIds.map(getPlayer));
    const losers = await Promise.all(loserIds.map(getPlayer));

    console.log({ winnerId, loserId: loserId, sport, winners, losers });

    const someWinnersCouldNotBeFound = !winners.every(isDefined);
    const someLosersCouldNotBeFound = !losers.every(isDefined);

    if (someWinnersCouldNotBeFound || someLosersCouldNotBeFound) {
      const errors: Array<ErrorWithMessage> = [];

      if (someWinnersCouldNotBeFound) {
        errors.push({
          errorCode: ErrorCodes.WinnerNotFound,
          message: `Player with id '${winnerId} not found`,
        });
        return;
      }

      if (someLosersCouldNotBeFound) {
        errors.push({
          errorCode: ErrorCodes.LoserNotFound,
          message: `Player with id '${loserId} not found`,
        });
      }

      sendErrorStatus(response, HttpStatus.BAD_REQUEST, errors);
      return;
    }

    const allPlayers = [...winners, ...losers];
    const isDebug = loserIds?.some(id => testIds.includes(id));
    if (!isDebug) {
      const allPlayersArePartOfATeam = allPlayers.every(validateTeam);
      if (!allPlayersArePartOfATeam) {
        const errors: Array<ErrorWithMessage> = [];

        const playersWithoutATeam = allPlayers.filter(
          player => !validateTeam(player),
        );
        playersWithoutATeam.map(player => ({
          errorCode: ErrorCodes.PlayerMissingTeam,
          message: `Player with id '${player} is not part of a team`,
        }));

        sendErrorStatus(response, HttpStatus.BAD_REQUEST, errors);
        return;
      }
    }

    winners.forEach(setEmptyPlayerStats);
    losers.forEach(setEmptyPlayerStats);

    const winnerStats = winners.map(winner => getSportStats(winner, sport));
    const loserStats = losers.map(loser => getSportStats(loser, sport));

    if (!winnerStats.every(isDefined) || !loserStats.every(isDefined)) {
      throw new Error(`Missing stats for sport ${sport}`);
    }

    const averageWinnerScore =
      winnerStats.reduce(
        (sum, { score }) => (sum += score ?? initialScore),
        0,
      ) / winners.length;
    const averageLoserScore =
      loserStats.reduce((sum, { score }) => (sum += score ?? initialScore), 0) /
      losers.length;

    // const oldWinnerScore = winnerStats.score ?? initialScore;
    // const oldLoserScore = loserStats.score ?? initialScore;

    const { playerRating: newWinnerScore, opponentRating: newLoserScore } =
      EloRating.calculate(averageWinnerScore, averageLoserScore);

    const delta = newWinnerScore - averageWinnerScore;

    console.log({ newWinnerScore, newLoserScore });

    const now = new firebase.firestore.Timestamp(
      Math.floor(Date.now() / 1000),
      0,
    );

    const match: Match = {
      date: now,
      sport,
      winner: winners[0],
      loser: losers[0],
      winners,
      losers,
      winnerDelta: delta,
      loserDelta: -delta,
    };

    const sameTeam = allPlayers.every(
      player =>
        (player.teamId ?? player.team?.id) ===
        (winners[0].teamId ?? winners[0].team?.id),
    );

    if (sameTeam) {
      match.teamId = winners[0].teamId ?? winners[0].team.id ?? undefined;
    }

    const allStats = [...winnerStats, ...loserStats];
    allStats.forEach(player => {
      player.matchesPlayed += 1;
    });

    winnerStats.forEach(winner => {
      winner.matchesWon += 1;
      winner.score += delta;
    });

    loserStats.forEach(loser => {
      loser.score -= delta;
    });

    allPlayers.forEach(player => {
      player.lastActive = now;
    });

    winners.forEach(winner => {
      winner.winStreak += 1;
    });

    losers.forEach(loser => {
      loser.winStreak = 0;
    });

    if (!isDebug) {
      addMatch(match);

      allPlayers.forEach(player => {
        updatePlayer(player);
      });
    }

    console.log({ match });

    response.send(match);
  },
);
