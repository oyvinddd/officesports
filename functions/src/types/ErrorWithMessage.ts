import { ErrorCodes } from "./ErrorCodes";

export type ErrorWithMessage = {
  errorCode: ErrorCodes;
  message: string;
};
