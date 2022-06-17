declare module "elo-rating" {
  export function calculate (playerScore: number, opponentScore: number, playerWon?: boolean): {playerRating: number, opponentRating: number} ;
}