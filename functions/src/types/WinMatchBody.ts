import { Sport } from "./Sport";

export type WinMatchBody = {
  winnerId: string;
  loserId: string;
  sport: Sport;
};
