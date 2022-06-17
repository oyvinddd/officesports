import { initializeApp, firestore } from "firebase-admin";
import type { Player } from "../types/Player";
initializeApp({
  storageBucket: "officesports-5d7ac.appspot.com",
});

const getCollection = <Type = firestore.DocumentData>(
  collectionName: string,
): firestore.CollectionReference<Type> =>
  firestore().collection(collectionName) as firestore.CollectionReference<Type>;

const getPlayerCollection = () => getCollection<Player>("players");
// const getInviteCollection = () => getCollection("invites");

const playerConverter: firestore.FirestoreDataConverter<Player> = {
  fromFirestore: snapshot => ({
    userId: snapshot.id,
    emoji: snapshot.get("emoji"),
    nickname: snapshot.get("nickname"),
    foosballStats: snapshot.get("foosballStats"),
    tableTennisStats: snapshot.get("tableTennisStats"),
  }),
  toFirestore: player => ({
    id: player.userId,
    emoji: player.emoji,
    nickname: player.nickname,
    foosballStats: player.foosballStats,
    tableTennisStats: player.tableTennisStats,
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
