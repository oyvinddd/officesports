import { createHmac } from "node:crypto";

export const hash = (password: string): string => {
  return createHmac("sha512", process.env.TEAM_PASSWORD_KEY ?? "")
    .update(password)
    .digest("hex");
};
