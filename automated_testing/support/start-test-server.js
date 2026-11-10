// Starts the system with a clean database, separate from data/db.json.
const fs = require('node:fs');

fs.rmSync(process.env.DB_PATH, { force: true });
require('../../application/src/server.js');
