import { Block, KnownBlock } from "@slack/web-api";

export type SlackCommandResponse = {
  response_type: "ephemeral" | "in_channel";
  blocks: Array<Block | KnownBlock>;
};
