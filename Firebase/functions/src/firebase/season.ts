import * as admin from "firebase-admin";
import { getCollection } from "../helpers/firebase.helpers";
import { Player } from "../types/Player";
import { Season } from "../types/Season";
import { Sport } from "../types/Sport";

const getSeasonCollection = () => getCollection<Season>("seasons");

const seasonConverter: admin.firestore.FirestoreDataConverter<Season> = {
  fromFirestore: snapshot => {
    const season: Season = {
      date: snapshot.get("date"),
      sport: snapshot.get("sport"),
      winner: snapshot.get("winner"),
      teamId: snapshot.get("teamId"),
    };

    return season;
  },
  toFirestore: season => season,
};

export const storeSeason = async (
  winner: Player,
  sport: Sport,
  date: admin.firestore.Timestamp,
  teamId: string,
): Promise<void> => {
  await getSeasonCollection()
    .withConverter(seasonConverter)
    .add({ winner, sport, date, teamId });
};
