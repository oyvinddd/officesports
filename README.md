## Office Sports

![Office Sports banner](https://github.com/oyvinddd/officesports/blob/main/Images/office-sports-banner.png "Office Sports banner")

![Office Sports screens](https://github.com/oyvinddd/officesports/blob/main/Images/office-sports-screens.png "Office Sports screens")

### Introduction

Office Sports is an app where users can keep track of scores against colleagues in foosball or table tennis. Using the app, players can register match results (by scannig the opponents QR code) and view the scoreboard as well as recent matches. Users are also able to invite other players to a match directly inside the app. Scores are calculated according to the [ELO](https://en.wikipedia.org/wiki/Elo_rating_system) rating system, which is done using a Firebase cloud function.    

### Technical Details

The app is written in Swift 5 and all UI is built programmatically. Screens will gradually be refactored to SwiftUI. [Firebase](https://firebase.google.com) (Firestore) is used as the backend and users sign in using their Google accounts. An MVVM (model-view-viewmodel) architecture is used for structring the code.

### Dependencies

SPM (Swift Package Manager) is used for dependency management. Currently, the only dependency is the Firebase iOS SDK.
