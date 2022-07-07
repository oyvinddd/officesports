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
};
