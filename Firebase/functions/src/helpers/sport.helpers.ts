import { initialScore } from "../constants";
import { Player } from "../types/Player";
import { Sport } from "../types/Sport";
import { Stats } from "../types/Stats";

export const getEmptyStats = (sport: Sport): Stats => ({
  matchesPlayed: 0,
  matchesWon: 0,
  score: initialScore,
  sport,
  seasonWins: 0,
});

export const sportNames: Record<Sport, string> = {
  [Sport.Foosball]: "foosball",
  [Sport.TableTennis]: "table tennis",
  [Sport.Pool]: "pool",
  [Sport.Unknown]: "unknown",
};

export const getSportStats = (player: Player, sport: Sport): Stats => {
  switch (sport) {
    case Sport.Foosball:
      return (player.foosballStats ??= getEmptyStats(Sport.Foosball));
    case Sport.TableTennis:
      return (player.tableTennisStats ??= getEmptyStats(Sport.TableTennis));
    case Sport.Pool:
      return (player.poolStats ??= getEmptyStats(Sport.Pool));
    default:
      throw new Error(`Sport '${sport}' is not allowed.`);
  }
};
