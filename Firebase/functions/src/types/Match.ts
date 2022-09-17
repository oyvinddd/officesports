import type * as firebase from "firebase-admin";
import { Player } from "./Player";
import { Sport } from "./Sport";

export type Match = {
  date: firebase.firestore.Timestamp;
  sport: Sport;
  winner: Player;
  loser: Player;
  winners: Array<Player>;
  losers: Array<Player>;
  winnerDelta: number;
  loserDelta: number;
  teamId?: string;
};
