import type * as functions from "firebase-functions";
import HttpStatus from "http-status-enum";
import { ErrorWithMessage } from "../types/ErrorWithMessage";

export const sendErrorStatus = (
  response: functions.Response,
  code: HttpStatus,
  errors: Array<ErrorWithMessage>,
): void => {
  response.status(code).send({
    errors,
  });
};
