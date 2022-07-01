import { Player } from "../types/Player";
import { Sport } from "../types/Sport";
import { Stats } from "../types/Stats";

export const setEmptyPlayerStats = (
  player: Player,
  defaultScore: number,
): void => {
  if (!player.foosballStats) {
    player.foosballStats = {
      matchesPlayed: 0,
      score: defaultScore,
      sport: Sport.Foosball,
      seasonWins: 0,
    };
  }

  if (!player.tableTennisStats) {
    player.tableTennisStats = {
      matchesPlayed: 0,
      score: defaultScore,
      sport: Sport.TableTennis,
      seasonWins: 0,
    };
  }
};

export const getSportStats = (
  player: Player,
  sport: Sport,
): Stats => {
  switch (sport) {
    case Sport.Foosball:
      return player.foosballStats!;
    case Sport.TableTennis:
      return player.tableTennisStats!;
    case Sport.Unknown:
    default:
      throw new Error(`Sport '${sport}' is not allowed.`);
  }
};
