import * as admin from "firebase-admin";
import { getCollection } from "../helpers/firebase.helpers";
import { getEmptyStats } from "../helpers/sport.helpers";
import { Player } from "../types/Player";
import { Sport } from "../types/Sport";

const getPlayerCollection = () => getCollection<Player>("players");

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
      lastActive: snapshot.get("lastActive"),
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

export const getPlayer = async (id: string): Promise<Player | undefined> => {
  const playerSnap = await getPlayerCollection()
    .withConverter(playerConverter)
    .doc(id)
    .get();

  const player = playerSnap.data();
  return player;
};

export const getPlayers = async (teamId?: string): Promise<Array<Player>> => {
  const collection = getPlayerCollection();
  let query: admin.firestore.Query<Player>;

  if (teamId) {
    query = collection.where("team.id", "==", teamId);
  } else {
    query = collection;
  }

  const snapshots = (await query.withConverter(playerConverter).get()).docs;
  return snapshots.map(snapshot => snapshot.data());
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
    teamId: player.teamId ?? player.team.id ?? undefined,
    lastActive: player.lastActive,
  };

  await getPlayerCollection()
    .withConverter(playerConverter)
    .doc(player.userId)
    .update(updatedPlayer);
};
