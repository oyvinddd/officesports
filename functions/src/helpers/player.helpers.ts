import { Player } from "../types/Player";
import { Sport } from "../types/Sport";

export const setEmptyPlayerStats = (
  player: Player,
  defaultScore: number,
): void => {
  if (!player.foosballStats) {
    player.foosballStats = {
      matchesPlayed: 0,
      score: defaultScore,
      sport: Sport.Foosball,
    };
  }

  if (!player.tableTennisStats) {
    player.tableTennisStats = {
      matchesPlayed: 0,
      score: defaultScore,
      sport: Sport.TableTennis,
    };
  }
};
