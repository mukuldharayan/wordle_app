const express = require('express');
const cors = require('cors');
require('dotenv').config();
const createPool = require('./db');

const app = express();
app.use(cors());
app.use(express.json());

let pool;
(async () => {
pool = await createPool();
})();

// Classic word
app.get('/word/classic', async (req, res) => {
    try {
      const [rows] = await pool.query(
        "SELECT word FROM words WHERE mode = 'classic' ORDER BY RAND() LIMIT 1"
      );
      if (rows.length === 0) {
        return res.status(404).json({ error: 'No classic word found' });
      }
      const word = rows[0].word;
      console.log('Classic word:', word);
      return res.json({ word });
    } catch (err) {
      console.error('Error querying classic word:', err);
      return res.status(500).json({ error: 'Server error' });
    }
  });
  
  // Timed word
  app.get('/word/timed', async (req, res) => {
    try {
      const [rows] = await pool.query(
        "SELECT word FROM words WHERE mode = 'timed' ORDER BY RAND() LIMIT 1"
      );
      if (rows.length === 0) {
        return res.status(404).json({ error: 'No timed word found' });
      }
      const word = rows[0].word;
      console.log('Timed word:', word);
      return res.json({ word });
    } catch (err) {
      console.error('Error querying timed word:', err);
      return res.status(500).json({ error: 'Server error' });
    }
  });

app.post('/score', async (req, res) => {
const { playerName, mode, attempts, success, timeTakenSeconds } = req.body;
try {
await pool.query(
'INSERT INTO scores (player_name, mode, attempts, success, time_taken_seconds) VALUES (?, ?, ?, ?, ?)',
[playerName || null, mode || 'classic', attempts, success ? 1 : 0, timeTakenSeconds || null]
);
res.json({ status: 'ok' });
} catch (err) {
console.error(err);
res.status(500).json({ error: 'Server error' });
}
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
console.log('Server running on port ' + PORT);
});