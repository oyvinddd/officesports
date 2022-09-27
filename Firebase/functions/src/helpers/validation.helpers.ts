import { ErrorCodes } from "../types/ErrorCodes";
import { ErrorWithMessage } from "../types/ErrorWithMessage";
import { JoinTeamBody } from "../types/JoinTeamBody";
import { Sport } from "../types/Sport";
import { WinMatchBody } from "../types/WinMatchBody";

const playerIdIsValid = (playerId: string): boolean => {
  return !!playerId;
};

const playerIdsAreValid = (winnerId: string, loserId: string): boolean => {
  return winnerId !== loserId;
};

const sportIsValid = (sport: Sport): boolean => {
  return [Sport.Foosball, Sport.TableTennis, Sport.Pool].includes(sport);
};

const teamIdIsValid = (teamId: string): boolean => {
  return !!teamId;
};

export const validateWinMatchBody = ({
  winnerId,
  loserId,
  sport,
}: WinMatchBody): Array<ErrorWithMessage> | null => {
  const errors: Array<ErrorWithMessage> = [];

  if (!playerIdIsValid(winnerId)) {
    errors.push({
      errorCode: ErrorCodes.InvalidWinnerId,
      message: `Winner's id '${winnerId}' is invalid`,
    });
  }

  if (!playerIdIsValid(loserId)) {
    errors.push({
      errorCode: ErrorCodes.InvalidLoserId,
      message: `Loser's id '${winnerId}' is invalid`,
    });
  }

  if (!playerIdsAreValid(winnerId, loserId)) {
    errors.push({
      errorCode: ErrorCodes.InvalidPlayerIds,
      message: `Winner id and loser id are equal ('${winnerId}')}`,
    });
  }

  if (!sportIsValid(sport)) {
    errors.push({
      errorCode: ErrorCodes.InvalidSport,
      message: `Sport '${sport}' is not a valid sport`,
    });
  }

  return errors.length > 0 ? errors : null;
};

export const validateJoinTeamBody = ({
  teamId,
  playerId,
}: JoinTeamBody): Array<ErrorWithMessage> => {
  const errors: Array<ErrorWithMessage> = [];

  if (!playerIdIsValid(playerId)) {
    errors.push({
      errorCode: ErrorCodes.InvalidPlayerId,
      message: "Missing player id",
    });
  }

  if (!teamIdIsValid(teamId)) {
    errors.push({
      errorCode: ErrorCodes.InvalidTeamId,
      message: "Missing team id",
    });
  }

  return errors;
};
