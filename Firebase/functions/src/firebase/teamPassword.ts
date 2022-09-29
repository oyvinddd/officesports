import { getCollection } from "../helpers/firebase.helpers";
import { TeamPassword } from "../types/TeamPassword";

const getTeamPasswordCollection = () =>
  getCollection<TeamPassword>("teamPasswords");

export const getTeamPassword = async (
  teamId: string,
): Promise<TeamPassword | undefined> => {
  return (
    await getTeamPasswordCollection()
      .where("teamId", "==", teamId)
      .limit(1)
      .get()
  ).docs[0]?.data();
};
