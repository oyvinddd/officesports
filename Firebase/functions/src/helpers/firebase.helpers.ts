import * as admin from "firebase-admin";
import { Match } from "../types/Match";
import type { Player } from "../types/Player";
import { Season } from "../types/Season";
import { Sport } from "../types/Sport";
import { getEmptyStats, getSportScore, getSportStats } from "./sport.helpers";

admin.initializeApp({
  storageBucket: "officesports-5d7ac.appspot.com",
});
admin.firestore().settings({ ignoreUndefinedProperties: true });

const getCollection = <Type = admin.firestore.DocumentData>(
  collectionName: string,
): admin.firestore.CollectionReference<Type> =>
  admin
    .firestore()
    .collection(collectionName) as admin.firestore.CollectionReference<Type>;

const getPlayerCollection = () => getCollection<Player>("players");
const getMatchCollection = () => getCollection<Match>("matches");
const getSeasonCollection = () => getCollection<Season>("seasons");

const playerConverter: admin.firestore.FirestoreDataConverter<Player> = {
  fromFirestore: snapshot => {
    const player: Player = {
      userId: snapshot.id,
      emoji: snapshot.get("emoji"),
      nickname: snapshot.get("nickname"),
      foosballStats: snapshot.get("foosballStats"),
      poolStats: snapshot.get("poolStats"),
      tableTennisStats: snapshot.get("tableTennisStats"),
      team: snapshot.get("team"),
      teamId: snapshot.get("teamId") ?? snapshot.get("team").id,
      stats: snapshot.get("stats") ?? [snapshot.get("foosballStats")],
    };

    return player;
  },
  toFirestore: player => ({
    emoji: player.emoji,
    nickname: player.nickname,
    foosballStats: player.foosballStats,
    poolStats: player.poolStats,
    tableTennisStats: player.tableTennisStats,
    team: player.team,
    // @ts-expect-error `player.team` is a Team (or undefined)
    teamId: player.teamId ?? player.team?.id,
  }),
};

const matchConverter: admin.firestore.FirestoreDataConverter<Match> = {
  fromFirestore: snapshot => {
    const match: Match = {
      date: snapshot.get("date"),
      loser: snapshot.get("loser"),
      loserDelta: snapshot.get("loserDelta"),
      sport: snapshot.get("sport"),
      winner: snapshot.get("winner"),
      winnerDelta: snapshot.get("winnerDelta"),
    };

    return match;
  },
  toFirestore: match => match,
};

const seasonConverter: admin.firestore.FirestoreDataConverter<Season> = {
  fromFirestore: snapshot => {
    const season: Season = {
      date: snapshot.get("date"),
      sport: snapshot.get("sport"),
      winner: snapshot.get("winner"),
    };

    return season;
  },
  toFirestore: season => season,
};

export const getPlayer = async (id: string): Promise<Player | undefined> => {
  const playerSnap = await getPlayerCollection()
    .withConverter(playerConverter)
    .doc(id)
    .get();

  const player = playerSnap.data();
  return player;
};

export const updatePlayer = async (player: Player): Promise<void> => {
  const updatedPlayer: Omit<Player, "userId"> = {
    emoji: player.emoji,
    nickname: player.nickname,
    foosballStats: player.foosballStats ?? getEmptyStats(Sport.Foosball),
    tableTennisStats:
      player.tableTennisStats ?? getEmptyStats(Sport.TableTennis),
    poolStats: player.poolStats ?? getEmptyStats(Sport.Pool),
    stats: player.stats ?? [
      player.foosballStats ?? getEmptyStats(Sport.Foosball),
      player.tableTennisStats ?? getEmptyStats(Sport.TableTennis),
      player.poolStats ?? getEmptyStats(Sport.Pool),
    ],
    team: player.team,
    teamId: player.teamId ?? player.team.id,
  };

  await getPlayerCollection()
    .withConverter(playerConverter)
    .doc(player.userId)
    .update(updatedPlayer);
};

export const addMatch = async (match: Match): Promise<void> => {
  await getMatchCollection().withConverter(matchConverter).add(match);
};

export const getLeader = async (
  sport: Sport,
  team?: string,
): Promise<Player | null> => {
  const allPlayers = getPlayerCollection();
  let playerQuery;

  if (team) {
    playerQuery = allPlayers.where("team.id", "==", team);
  } else {
    playerQuery = allPlayers;
  }

  const getSpecificSportScore = getSportScore(sport);
  const sortBySportScoreDesc = (player1: Player, player2: Player) =>
    getSpecificSportScore(player2) - getSpecificSportScore(player1);

  const playerSnap = await playerQuery.withConverter(playerConverter).get();

  const [firstPlace, secondPlace] = playerSnap.docs
    .map(playerSnap => playerSnap.data())
    .sort(sortBySportScoreDesc);

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

export const getAllPlayers = async (): Promise<Array<Player>> => {
  const playerSnapshots = (
    await getPlayerCollection().withConverter(playerConverter).get()
  ).docs;
  return playerSnapshots.map(player => player.data());
};

export const resetScoreboards = async (initialScore: number): Promise<void> => {
  const allPlayers = await getAllPlayers();

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

export const storeSeason = async (
  winner: Player,
  sport: Sport,
  date: admin.firestore.Timestamp,
): Promise<void> => {
  await getSeasonCollection()
    .withConverter(seasonConverter)
    .add({ winner, sport, date });
};
