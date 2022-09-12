import { firestore } from "firebase-admin";
import { Player } from "./Player";
import { Sport } from "./Sport";

export type Season = {
  date: firestore.Timestamp;
  winner: Player;
  sport: Sport;
  teamId: string;
};
