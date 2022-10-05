import * as admin from "firebase-admin";
import { getPlayers, updatePlayer } from "../firebase/player";
import type { Player } from "../types/Player";
import { Sport } from "../types/Sport";
import { getSportScore, getSportStats } from "./sport.helpers";

admin.initializeApp({
  storageBucket: "officesports-5d7ac.appspot.com",
});
admin.firestore().settings({ ignoreUndefinedProperties: true });

export const getCollection = <Type = admin.firestore.DocumentData>(
  collectionName: string,
): admin.firestore.CollectionReference<Type> =>
  admin
    .firestore()
    .collection(collectionName) as admin.firestore.CollectionReference<Type>;

export const getLeader = async (
  sport: Sport,
  teamId?: string,
): Promise<Player | null> => {
  const getSpecificSportScore = getSportScore(sport);
  const sortBySportScoreDesc = (player1: Player, player2: Player) =>
    getSpecificSportScore(player2) - getSpecificSportScore(player1);

  const allPlayers = await getPlayers(teamId);
  const [firstPlace, secondPlace] = allPlayers.sort(sortBySportScoreDesc);

  if (!firstPlace) {
    return null;
  }

  if (!secondPlace) {
    return firstPlace;
  }

  const firstPlaceStats = getSportStats(firstPlace, sport);
  const secondPlaceStats = getSportStats(secondPlace, sport);

  const winnerHasPlayedAtLeastOnce = firstPlaceStats?.score != null;
  const moreThanOneWinner = firstPlaceStats?.score === secondPlaceStats?.score;

  if (!winnerHasPlayedAtLeastOnce || moreThanOneWinner) {
    return null;
  }

  return firstPlace;
};

export const incrementTotalSeasonWins = async (
  player: Player,
  sport: Sport,
) => {
  const stats = getSportStats(player, sport);
  stats.seasonWins += 1;

  updatePlayer(player);
};

export const resetScoreboards = async (initialScore: number): Promise<void> => {
  const allPlayers = await getPlayers();

  console.log("All players", allPlayers);

  for (const player of allPlayers) {
    if (player.foosballStats) {
      player.foosballStats.score = initialScore;
      player.foosballStats.matchesPlayed = 0;
      player.foosballStats.matchesWon = 0;
    }

    if (player.tableTennisStats) {
      player.tableTennisStats.score = initialScore;
      player.tableTennisStats.matchesPlayed = 0;
      player.tableTennisStats.matchesWon = 0;
    }

    if (player.poolStats) {
      player.poolStats.score = initialScore;
      player.poolStats.matchesPlayed = 0;
      player.poolStats.matchesWon = 0;
    }

    for (const stat of player.stats) {
      stat.score = initialScore;
      stat.matchesPlayed = 0;
      stat.matchesWon = 0;
    }

    await updatePlayer(player);
  }
};
