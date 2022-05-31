import type { Stats } from "./Stats";

export type Player = {
  userId: string;
  nickname: string;
  emoji: string;
  foosballStats: Stats;
  tableTennisStats: Stats;
};
