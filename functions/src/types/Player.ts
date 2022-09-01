import type { Stats } from "./Stats";
import type { Team } from "./Team";

export type Player = {
  userId: string;
  nickname: string;
  emoji: string;
  foosballStats?: Stats;
  tableTennisStats?: Stats;
  team?: Team;
};
