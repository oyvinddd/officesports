import { Player } from "../types/Player";
import { Sport } from "../types/Sport";
import { getEmptyStats } from "./sport.helpers";

export const setEmptyPlayerStats = (player: Player): void => {
  if (!player.foosballStats) {
    player.foosballStats = getEmptyStats(Sport.Foosball);
  }

  if (!player.tableTennisStats) {
    player.tableTennisStats = getEmptyStats(Sport.TableTennis);
  }

  if (!player.poolStats) {
    player.poolStats = getEmptyStats(Sport.Pool);
  }

  // if (!player.stats) {
  player.stats = [
    player.foosballStats ?? getEmptyStats(Sport.Foosball),
    player.tableTennisStats ?? getEmptyStats(Sport.TableTennis),
    player.poolStats ?? getEmptyStats(Sport.Pool),
  ];
  // }
};

export const getEmptyPlayer = (): Omit<Player, "userId"> => {
  return {
    emoji: "🔳",
    nickname: "nickname",
    stats: [
      getEmptyStats(Sport.Foosball),
      getEmptyStats(Sport.TableTennis),
      getEmptyStats(Sport.Pool),
    ],
    winStreak: 0,
    lastActive: null,
    teamId: null,
    team: { id: null, name: "No team" },
  };
};
