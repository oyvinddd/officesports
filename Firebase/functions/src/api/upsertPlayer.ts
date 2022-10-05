import * as functions from "firebase-functions";
import HttpStatus from "http-status-enum";
import { createPlayer, getPlayers, updatePlayer } from "../firebase/player";
import { sendErrorStatus } from "../helpers/api.helpers";
import { isDefined } from "../helpers/type.helpers";
import { ErrorCodes } from "../types/ErrorCodes";
import { Player } from "../types/Player";

type UpsertPlayerBody = {
  player: Omit<Player, "userId"> & { userId?: string };
};

export const upsertPlayer = functions.https.onRequest(
  async (request, response): Promise<void> => {
    const isPost = request.method === "POST";
    if (!isPost) {
      sendErrorStatus(response, HttpStatus.METHOD_NOT_ALLOWED, [
        {
          errorCode: ErrorCodes.UpsertPlayerMethodNotAllowed,
          message: `Method '${request.method}' is not allowed`,
        },
      ]);
      return;
    }

    const { player } = request.body as UpsertPlayerBody;
    const allPlayers = await getPlayers();
    const existingPlayerWithSameNickname = allPlayers
      .filter(isDefined)
      .find(p => p.nickname === player.nickname);

    // TODO: Validate nickname
    if (!player.nickname || player.nickname.length < 3) {
      sendErrorStatus(response, HttpStatus.BAD_REQUEST, [
        {
          errorCode: ErrorCodes.NicknameDoesNotValidate,
          message: `Nickname \`${player.nickname}\` does not validate`,
        },
      ]);

      return;
    }

    if (player.userId) {
      // Player exists

      const nicknameIsTakenByAnotherPlayer =
        existingPlayerWithSameNickname?.userId !== player.userId;

      if (nicknameIsTakenByAnotherPlayer) {
        sendErrorStatus(response, HttpStatus.BAD_REQUEST, [
          {
            errorCode: ErrorCodes.NicknameIsAlreadyTaken,
            message: `Nickname \`${player.nickname}\` is already taken`,
          },
        ]);
        return;
      }

      await updatePlayer({ userId: player.userId, ...player });

      response.send({ success: true });

      return;
    }

    try {
      if (existingPlayerWithSameNickname) {
        sendErrorStatus(response, HttpStatus.BAD_REQUEST, [
          {
            errorCode: ErrorCodes.NicknameIsAlreadyTaken,
            message: `Nickname \`${player.nickname}\` is already taken`,
          },
        ]);
        return;
      }

      const newPlayer = await createPlayer(player);
      response.send({ success: true, player: newPlayer });
    } catch (e) {
      if (e instanceof Error) {
        sendErrorStatus(response, HttpStatus.BAD_REQUEST, [
          {
            errorCode: ErrorCodes.CouldNotCreatePlayer,
            message: e.message,
          },
        ]);

        return;
      }

      sendErrorStatus(response, HttpStatus.BAD_REQUEST, [
        {
          errorCode: ErrorCodes.CouldNotCreatePlayer,
          message: "Unknown reason",
        },
      ]);
    }
  },
);
