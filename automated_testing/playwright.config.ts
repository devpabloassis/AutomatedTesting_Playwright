import { defineConfig, devices } from '@playwright/test';
import { defineBddProject } from 'playwright-bdd';

const PORT = process.env.TEST_PORT ?? '3100';
const BASE_URL = `http://127.0.0.1:${PORT}`;

const bdd = { language: 'pt' };

export default defineConfig({
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  // Sem retentativas: os defeitos intencionais devem aparecer como falhas diretas.
  retries: 0,
  reporter: [
    ['list'],
    ['html', { open: 'never' }],
    ['junit', { outputFile: 'test-results/junit.xml' }],
  ],
  use: {
    baseURL: BASE_URL,
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  webServer: {
    command: 'node support/start-test-server.js',
    url: `${BASE_URL}/api/companies`,
    reuseExistingServer: false,
    env: { PORT, DB_PATH: '.test-data/db.json' },
  },
  projects: [
    defineBddProject({
      ...bdd,
      name: 'api',
      features: 'features/api/*.feature',
      steps: ['support/fixtures.ts', 'steps/common.steps.ts', 'steps/api.steps.ts'],
    }),
    {
      ...defineBddProject({
        ...bdd,
        name: 'web-chromium',
        features: 'features/web/*.feature',
        steps: ['support/fixtures.ts', 'steps/common.steps.ts', 'steps/web.steps.ts'],
      }),
      use: { ...devices['Desktop Chrome'] },
    },
  ],
});
