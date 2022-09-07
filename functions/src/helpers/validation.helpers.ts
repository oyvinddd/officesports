import { ErrorCodes } from "../types/ErrorCodes";
import { ErrorWithMessage } from "../types/ErrorWithMessage";
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
