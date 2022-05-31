import * as admin from "firebase-admin";
import type { Player } from "../types/Player";
admin.initializeApp();

const getCollection = <Type = admin.firestore.DocumentData>(
  collectionName: string,
): admin.firestore.CollectionReference<Type> =>
  admin
    .firestore()
    .collection(collectionName) as admin.firestore.CollectionReference<Type>;

const getPlayerCollection = () => getCollection<Player>("players");
// const getInviteCollection = () => getCollection("invites");

export const getPlayer = (id: string): Player | undefined => {
  getPlayerCollection().where("userId", "==", id).;
};
