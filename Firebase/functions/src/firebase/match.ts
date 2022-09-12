import * as admin from "firebase-admin";
import { getCollection } from "../helpers/firebase.helpers";
import { Match } from "../types/Match";

const getMatchCollection = () => getCollection<Match>("matches");

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

export const addMatch = async (match: Match): Promise<void> => {
  await getMatchCollection().withConverter(matchConverter).add(match);
};
