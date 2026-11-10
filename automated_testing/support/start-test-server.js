// Inicia o sistema com um banco limpo, separado de data/db.json.
const fs = require('node:fs');

fs.rmSync(process.env.DB_PATH, { force: true });
require('../../application/src/server.js');
