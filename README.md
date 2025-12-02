


Wordle Application (Flutter + Node.js + SQL)

A Wordle‑style word guessing game built with Flutter (web/desktop/mobile) and a Node.js + SQL backend.
Players try to guess a hidden 5‑letter word in up to 6 attempts, with color feedback for each letter, optional timed mode, and the ability to pause/resume and share results.

Features

-> Wordle‑style gameplay

-> 5‑letter target word.

-> Up to 6 guesses per game.

Tile colors:

-> Green: correct letter in correct position.

-> Orange: correct letter in wrong position.

-> Grey: letter not in the word.

Game modes

1. Classic mode: Unlimited time.
2. Timed mode: 60‑second countdown.

Game automatically ends when the timer hits zero.

Pause and resume

-> Pause button stops the timer (in timed mode) and saves the current game state.

-> Resume button continues from where you left off.

Persistent state (resume after closing app)

Current game (board, guesses, mode, remaining time) is saved locally using key‑value storage.

If the user closes and reopens the app, the last unfinished game is automatically restored.

Score sharing

-> After a game, the user can share a textual summary:

* Mode (Classic / Timed).

* Number of attempts or failure.

* Remaining time (for timed mode).

* List of guesses.

Backend‑driven words and score storage

Node.js + Express server with SQL (e.g., MySQL).

Endpoints:

GET /word/classic – fetch random classic word.

GET /word/timed – fetch random timed word.

POST /score – save score (name, mode, attempts, success, time).


Tech Stack


**Frontend**

Flutter

Dart


**Backend**

Node.js

Express

mysql2 (or compatible SQL driver)

SQL database (e.g., MySQL)


Backend Setup (Node.js + SQL)


Install dependencies

cd server
npm install
Create database and tables


Start your SQL server (e.g., MySQL).


Run sql/schema.sql in your DB client.

Example schema:

sql
CREATE DATABASE IF NOT EXISTS wordle_app;
USE wordle_app;

CREATE TABLE IF NOT EXISTS words (
  id INT AUTO_INCREMENT PRIMARY KEY,
  word VARCHAR(10) NOT NULL,
  mode ENUM('classic','timed') NOT NULL
);

CREATE TABLE IF NOT EXISTS scores (
  id INT AUTO_INCREMENT PRIMARY KEY,
  player_name VARCHAR(50),
  mode ENUM('classic','timed') NOT NULL,
  attempts INT,
  success TINYINT(1),
  time_taken_seconds INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
Seed words (example):

sql
INSERT INTO words (word, mode) VALUES
  ('APPLE','classic'),
  ('HOUSE','classic'),
  ('PHONE','classic'),
  ('CLOCK','timed'),
  ('TIMER','timed'),
  ('SPEED','timed');
Configure environment


Run the backend


cd server
node index.js
You should see:

Server running on port 3000
Test endpoints in your browser:

Classic word: http://localhost:3000/word/classic

Timed word: http://localhost:3000/word/timed


Frontend Setup (Flutter)


Prerequisites

Flutter SDK installed and in PATH.

Dart SDK (bundled with Flutter).

An IDE or editor (VS Code / Android Studio) with Flutter plugin.

Install Flutter dependencies

cd app
flutter pub get
Configure API base URL

Run on Chrome (web)

flutter run -d chrome
Or, choose Chrome when prompted by flutter run.

Run on mobile (optional)

Connect a device or start an emulator.

For Android emulator, update base URL to http://10.0.2.2:3000 and run:

flutter run -d android


**How to Play**


Start the app

Backend must be running on port 3000.

Open the Flutter app (web, desktop, or mobile).

1. Choose a mode

2. Use the menu (⋮) in the top‑right AppBar:

3. Classic: unlimited time; uses classic words.

4. Timed (60s): 60‑second countdown; uses timed words.

5. Make guesses

6. Tap/click letters on the on‑screen keyboard to build a 5‑letter word.

7. Current input is shown as Guess: XXXXX.

8. Press ENTER to submit.

Tiles update color to indicate correctness.

Pause / resume

Tap the pause icon (⏸) to pause and persist the current game.

Tap the play icon (▶) to resume.

Resume after closing

Close the app (or browser tab).

Reopen it later:

The last unfinished game (board, guesses, mode, remaining time) is automatically loaded from local storage.

Share score

After the game ends, tap the share icon.

The app opens the native share dialog with a summary text you can send via any app.
