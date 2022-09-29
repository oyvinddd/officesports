import * as admin from "firebase-admin";
import { getCollection } from "../helpers/firebase.helpers";
import { Team } from "../types/Team";

const getTeamCollection = () => getCollection<Team>("teams");

const teamConverter: admin.firestore.FirestoreDataConverter<Team> = {
  fromFirestore(snapshot) {
    const team: Team = {
      id: snapshot.id,
      name: snapshot.get("name"),
    };

    return team;
  },
  toFirestore(team) {
    return {
      name: team.name,
    };
  },
};

export const getTeams = async (): Promise<Array<Team>> => {
  const { docs } = await getTeamCollection().withConverter(teamConverter).get();
  return docs.map(doc => doc.data());
};

export const getTeam = async (teamId: string): Promise<Team | undefined> => {
  const team = (
    await getTeamCollection().withConverter(teamConverter).doc(teamId).get()
  ).data();

  return team;
};
