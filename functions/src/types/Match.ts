import { Player } from "./Player";
import { Sport } from "./Sport";

export type Match = {
  date: string;
  sport: Sport;
  winner: Player;
  loser: Player;
  winnerDelta: number;
  loserDelta: number;
};
