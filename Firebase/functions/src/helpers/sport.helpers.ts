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
  [Sport.VideoGames]: "video games",
};

export const getSportStats = (player: Player, sport: Sport): Stats => {
  // TODO: Remove when `player.*Stats` are removed
  if (player.stats?.length !== 3) {
    player.stats = [
      player.foosballStats ?? getEmptyStats(Sport.Foosball),
      player.tableTennisStats ?? getEmptyStats(Sport.TableTennis),
      player.poolStats ?? getEmptyStats(Sport.Pool),
    ];
  }

  switch (sport) {
    case Sport.Foosball:
      return (player.foosballStats ??= getEmptyStats(Sport.Foosball));
    case Sport.TableTennis:
      return (player.tableTennisStats ??= getEmptyStats(Sport.TableTennis));
    case Sport.Pool:
      return (player.poolStats ??= getEmptyStats(Sport.Pool));
  }

  // const sportStats = player.stats.find(stat => stat.sport === sport);
  // if (sportStats) {
  //   return sportStats;
  // }

  return getEmptyStats(sport);
};

export const getSportScore =
  (sport: Sport) =>
  (player: Player): number =>
    player.stats.find(stat => stat.sport === sport)?.score ?? 0;
