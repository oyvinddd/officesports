import * as functions from "firebase-functions";
import HttpStatus from "http-status-enum";
import { getPlayer, updatePlayer } from "../firebase/player";
import { getTeam } from "../firebase/team";
import { getTeamPassword } from "../firebase/teamPassword";
import { sendErrorStatus } from "../helpers/api.helpers";
import { hash } from "../helpers/team-password.helpers";
import { validateJoinTeamBody } from "../helpers/validation.helpers";
import { ErrorCodes } from "../types/ErrorCodes";
import { ErrorWithMessage } from "../types/ErrorWithMessage";
import { JoinTeamBody } from "../types/JoinTeamBody";
import { Player } from "../types/Player";
import { Team } from "../types/Team";

type ParsedBody = {
  team: Team;
  player: Player;
  password: string | undefined;
};

const isErrorWithMessage = (
  value: Record<string, unknown> | Array<ErrorWithMessage>,
): value is Array<ErrorWithMessage> => {
  return Array.isArray(value);
};

const parseBody = async ({
  teamId,
  playerId,
  password,
}: Partial<JoinTeamBody>): Promise<ParsedBody | Array<ErrorWithMessage>> => {
  const errors: Array<ErrorWithMessage> = [];

  const team = await getTeam(teamId ?? "");
  if (!team) {
    errors.push({
      errorCode: ErrorCodes.TeamNotFound,
      message: `Team with id '${teamId} was not found'`,
    });
  }

  const player = await getPlayer(playerId ?? "");
  if (!player) {
    errors.push({
      errorCode: ErrorCodes.TeamNotFound,
      message: `Team with id '${teamId} was not found'`,
    });
  }

  const hasErrors = errors.length > 0;
  if (hasErrors || !team || !player) {
    return errors;
  }

  return {
    team,
    player,
    password,
  };
};

export const joinTeam = functions.https.onRequest(
  async (request, response): Promise<void> => {
    functions.logger.info("Joining team", request.body);

    const bodyErrors = validateJoinTeamBody(request.body);
    const hasBodyErrors = bodyErrors.length > 0;
    if (hasBodyErrors) {
      sendErrorStatus(response, HttpStatus.BAD_REQUEST, bodyErrors);
      return;
    }

    const parseResult = await parseBody(request.body);
    if (isErrorWithMessage(parseResult)) {
      sendErrorStatus(response, HttpStatus.BAD_REQUEST, parseResult);
      return;
    }

    functions.logger.info("Body was successfully parsed", parseResult);

    const { teamId } = request.body;
    const { player, password } = parseResult;
    const teamPasswordHash = (await getTeamPassword(teamId))?.passwordHash;

    const hasPassword = !!teamPasswordHash;
    if (hasPassword) {
      const inputPasswordHash = hash(password ?? "");

      const passwordIsCorrect = inputPasswordHash === teamPasswordHash;
      if (!passwordIsCorrect) {
        sendErrorStatus(response, HttpStatus.UNAUTHORIZED, [
          {
            errorCode: ErrorCodes.InvalidTeamPassword,
            message: "Invalid team password",
          },
        ]);

        return;
      }
    }

    player.teamId = teamId;
    await updatePlayer(player);

    functions.logger.info("Player is updated", { player });

    response.send(player);
  },
);
