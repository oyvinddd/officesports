import * as admin from "firebase-admin";
import { Match } from "../types/Match";
import type { Player } from "../types/Player";
admin.initializeApp({
  storageBucket: "officesports-5d7ac.appspot.com",
});

const getCollection = <Type = admin.firestore.DocumentData>(
  collectionName: string,
): admin.firestore.CollectionReference<Type> =>
  admin
    .firestore()
    .collection(collectionName) as admin.firestore.CollectionReference<Type>;

const getPlayerCollection = () => getCollection<Player>("players");
const getMatchCollection = () => getCollection<Match>("matches");

const playerConverter: admin.firestore.FirestoreDataConverter<Player> = {
  fromFirestore: snapshot => ({
    userId: snapshot.id,
    emoji: snapshot.get("emoji"),
    nickname: snapshot.get("nickname"),
    foosballStats: snapshot.get("foosballStats"),
    tableTennisStats: snapshot.get("tableTennisStats"),
  }),
  toFirestore: player => ({
    emoji: player.emoji,
    nickname: player.nickname,
    foosballStats: player.foosballStats,
    tableTennisStats: player.tableTennisStats,
  }),
};

const matchConverter: admin.firestore.FirestoreDataConverter<Match> = {
  fromFirestore: snapshot => ({
    date: snapshot.get("date"),
    loser: snapshot.get("loser"),
    loserDelta: snapshot.get("loserDelta"),
    sport: snapshot.get("sport"),
    winner: snapshot.get("winner"),
    winnerDelta: snapshot.get("winnerDelta"),
  }),
  toFirestore: match => match,
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
  await getPlayerCollection()
    .withConverter(playerConverter)
    .doc(player.userId)
    .update({
      emoji: player.emoji,
      nickname: player.nickname,
      foosballStats: player.foosballStats,
      tableTennisStats: player.tableTennisStats,
    });
};

export const addMatch = async (match: Match): Promise<void> => {
  await getMatchCollection().withConverter(matchConverter).add(match);
};
