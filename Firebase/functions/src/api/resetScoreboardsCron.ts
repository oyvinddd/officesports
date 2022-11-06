import * as firebase from "firebase-admin";
import * as functions from "firebase-functions";
import {
  initialScore,
  tietoevryBankingTeamId,
  tietoevryCreateTeamId,
} from "../constants";
import { storeSeason } from "../firebase/season";
import { getTeams } from "../firebase/team";
import {
  getLeader,
  incrementTotalSeasonWins,
  resetScoreboards,
} from "../helpers/firebase.helpers";
import * as slackHelpers from "../helpers/slack.helpers";
import { sportNames } from "../helpers/sport.helpers";
import { Season } from "../types/Season";
import { Sport } from "../types/Sport";

const isSport = (value: string | Sport): value is Sport =>
  typeof value !== "string";

const resetScoreboardsFunction = async () => {
  const sports = Object.values(Sport).filter(isSport);

  const now = new Date();
  const seasonStartDate = new Date();
  seasonStartDate.setMonth(Math.abs((now.getMonth() - 1 + 12) % 12));

  const timestamp = new firebase.firestore.Timestamp(
    Math.floor(seasonStartDate.getTime() / 1000),
    0,
  );
  console.log("Timestamp:", timestamp);

  const seasonsWithWinners: Array<Season> = [];
  const teams = await getTeams();

  for (const team of teams) {
    const teamId = team.id;
    if (!teamId) {
      console.log("TeamId is undefiend");
      continue;
    }

    for (const sport of sports) {
      console.log("Calculating seasonal winner");
      const seasonWinner = await getLeader(sport, teamId);
      if (!seasonWinner) {
        console.log(
          `No seasonal winner found for ${team.name}, sport: ${sport}`,
        );
        continue;
      }

      console.log(`${sportNames[sport]} winner`, seasonWinner);
      await incrementTotalSeasonWins(seasonWinner, sport);

      console.log(`Storing ${sportNames[sport]} season`);
      await storeSeason(seasonWinner, sport, timestamp, teamId);

      seasonsWithWinners.push({
        winner: seasonWinner,
        sport,
        date: timestamp,
        teamId,
      });
    }

    console.log("Resetting score boards");
    await resetScoreboards(initialScore);

    const tietoevryCreateSeasons = seasonsWithWinners.filter(
      season => season.teamId === tietoevryCreateTeamId,
    );
    const tietoevryBankingSeasons = seasonsWithWinners.filter(
      season => season.teamId === tietoevryBankingTeamId,
    );

    await slackHelpers.postSeasonResults([
      tietoevryCreateSeasons,
      tietoevryBankingSeasons,
    ]);
  }
};

export const resetScoreboardsCron = functions
  .runWith({
    secrets: ["SLACK_TOKEN", "SLACK_CHANNEL"],
  })
  .pubsub.schedule("1 of month 00:00")
  .onRun(async () => {
    console.log("Resetting score boards");

    await resetScoreboardsFunction();

    console.log("Finished resetting score boards");
    return null;
  });
