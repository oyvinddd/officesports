import type { firestore } from "firebase-admin";
import type { Stats } from "./Stats";
import type { Team } from "./Team";

export type Player = {
  userId: string;
  nickname: string;
  emoji: string;
  /** @deprecated Use stats instead */
  foosballStats?: Stats;
  /** @deprecated Use stats instead */
  tableTennisStats?: Stats;
  /** @deprecated Use stats instead */
  poolStats?: Stats;
  stats: Array<Stats>;
  /** @deprecated Use teamId instead */
  team: Team;
  teamId?: string | null;
  lastActive?: firestore.Timestamp | null;
  winStreak: number;
};
