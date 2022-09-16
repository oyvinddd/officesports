import { Sport } from "./Sport";

export type WinMatchBody = {
  winnerId: string;
  winnerIds: Array<string>;
  loserId: string;
  loserIds: Array<string>;
  sport: Sport;
};
