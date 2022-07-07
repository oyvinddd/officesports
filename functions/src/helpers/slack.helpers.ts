import {
  Block,
  ChatPostMessageResponse,
  KnownBlock,
  WebClient,
} from "@slack/web-api";
import dotenv from "dotenv";
import { initialScore } from "../constants";
import { Player } from "../types/Player";
import { Season } from "../types/Season";
import { Sport } from "../types/Sport";
import { getSportName, getSportStats } from "./sport.helpers";

dotenv.config();

const slackToken = process.env.SLACK_TOKEN;
const channel = process.env.SLACK_CHANNEL;
const clientId = process.env.SLACK_CLIENT_ID;
const clientSecret = process.env.SLACK_CLIENT_SECRET;

const slackClient = new WebClient(slackToken);

const postMessage = async (
  text: string,
  blocks?: Array<Block | KnownBlock>,
): Promise<ChatPostMessageResponse> => {
  if (!channel) {
    throw new Error("Missing SLACK_CHANNEL environment variable");
  }

  return await slackClient.chat.postMessage({ text, blocks, channel });
};

const seasonToString = ({ sport, winner }: Season): string => {
  switch (sport) {
    case Sport.Foosball:
      return ` - ⚽️ Foosball: ${winner.nickname} ${winner.emoji} with ${winner.foosballStats?.score} points`;
    case Sport.TableTennis:
      return ` - 🏓 Table tennis: ${winner.nickname} ${winner.emoji} with ${winner.tableTennisStats?.score} points`;
    default:
      return "";
  }
};

export const postSeasonResults = async (
  seasons: Array<Season>,
): Promise<ChatPostMessageResponse> => {
  const monthFormatter = new Intl.DateTimeFormat("en", { month: "long" });

  const seasonSummaries = seasons.map(seasonToString).join("\n\n");
  const monthName = monthFormatter.format(seasons[0].date.toDate());

  const text = `
    ${monthName} is over! ${
    seasons.length === 0
      ? "We sadly had no winners this month :("
      : seasons.length === 1
      ? "This was the only winner this season:"
      : "These were the winners this season:"
  }

    ${seasonSummaries}
    
    All scores are now reset to ${initialScore}. Good luck for next season! 🥳
  `;

  return postMessage(text);
};

export const authenticate = async (code: string): Promise<string | null> => {
  console.log("authenticating");

  if (!clientId || !clientSecret) {
    console.error({ clientId, clientSecret });
    throw new Error("Missing client id or client secret");
  }
  const response = await slackClient.oauth.v2.access({
    code,
    client_id: clientId,
    client_secret: clientSecret,
  });

  console.log(JSON.stringify(response));

  if (response.ok && response.access_token) {
    return response.access_token;
  }

  return null;
};

export const formatLeaderText = (
  sport: Sport,
  leader: Player | null,
): Array<Block | KnownBlock> => {
  const sportName = getSportName(sport);

  if (!leader) {
    return [
      {
        type: "section",
        text: {
          type: "mrkdwn",
          text: `There is currently not only one 1st place on the ${sportName} leaderboard`,
        },
      },
    ];
  }

  const { score } = getSportStats(leader, sport);

  return [
    {
      type: "section",
      text: {
        type: "mrkdwn",
        text: `The current ${sportName} leader is ${leader.nickname} ${leader.emoji} with ${score} points.`,
      },
    },
  ];
};
