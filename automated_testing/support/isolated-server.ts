import { ChildProcess, spawn } from 'node:child_process';
import { once } from 'node:events';
import path from 'node:path';
import { setTimeout as delay } from 'node:timers/promises';

const SERVER_SCRIPT = path.resolve(__dirname, '../../application/src/server.js');

// Servidor e banco próprios, para cenários que precisam reiniciar o sistema.
export class IsolatedServer {
  private process?: ChildProcess;
  readonly url: string;

  constructor(
    private readonly port: number,
    readonly dbPath: string,
  ) {
    this.url = `http://127.0.0.1:${port}/api`;
  }

  async start() {
    this.process = spawn('node', [SERVER_SCRIPT], {
      env: { ...process.env, PORT: String(this.port), DB_PATH: this.dbPath },
      stdio: 'ignore',
    });
    for (let attempt = 0; attempt < 100; attempt++) {
      try {
        await fetch(`${this.url}/companies`);
        return;
      } catch {
        await delay(100);
      }
    }
    throw new Error(`O servidor não iniciou na porta ${this.port}.`);
  }

  async stop() {
    if (!this.process || this.process.exitCode !== null) return;
    const exited = once(this.process, 'exit');
    this.process.kill();
    await exited;
  }

  async restart() {
    await this.stop();
    await this.start();
  }
}
