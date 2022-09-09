import type { Stats } from "./Stats";
import type { Team } from "./Team";

export type Player = {
  userId: string;
  nickname: string;
  emoji: string;
  foosballStats?: Stats;
  tableTennisStats?: Stats;
  poolStats?: Stats;
  /** @deprecated Use teamId instead */
  team: Team;
  teamId: string;
};
