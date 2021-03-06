import { initialScore } from "../constants";
import { Player } from "../types/Player";
import { Sport } from "../types/Sport";
import { Stats } from "../types/Stats";

export const getEmptyStats = (sport: Sport): Stats => ({
  matchesPlayed: 0,
  score: initialScore,
  sport,
  seasonWins: 0,
});

export const getSportName = (sport: Sport): string => {
  switch (sport) {
    case Sport.Foosball:
      return "foosball";
    case Sport.TableTennis:
      return "table tennis";
    default:
      return "unknown";
  }
};

export const getSportStats = (player: Player, sport: Sport): Stats => {
  switch (sport) {
    case Sport.Foosball:
      return player.foosballStats ?? getEmptyStats(Sport.Foosball);
    case Sport.TableTennis:
      return player.tableTennisStats ?? getEmptyStats(Sport.TableTennis);
    default:
      throw new Error(`Sport '${sport}' is not allowed.`);
  }
};
