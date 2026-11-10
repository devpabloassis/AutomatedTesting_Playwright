// Contract validation: compares the API response with the JSON Schemas in contracts/.
import { readdirSync, readFileSync } from 'node:fs';
import path from 'node:path';
import Ajv, { ErrorObject } from 'ajv';
import addFormats from 'ajv-formats';

const CONTRACTS_DIR = path.join(__dirname, '..', 'contracts');

const ajv = new Ajv({ allErrors: true, strict: true });
addFormats(ajv);

// Each <name>.schema.json file is registered by its $id, which is the name itself.
for (const file of readdirSync(CONTRACTS_DIR).filter((name) => name.endsWith('.schema.json'))) {
  ajv.addSchema(JSON.parse(readFileSync(path.join(CONTRACTS_DIR, file), 'utf8')));
}

// "/0/products/1/name" becomes "[0].products[1].name", to make the error easier to read.
function fieldPath(instancePath: string, property?: string): string {
  const parts = [...instancePath.split('/').filter(Boolean), ...(property ? [property] : [])];
  const text = parts.map((part) => (/^\d+$/.test(part) ? `[${part}]` : `.${part}`)).join('');
  return text ? text.replace(/^\./, '') : '(root)';
}

function describe(error: ErrorObject): string {
  const params = error.params as Record<string, unknown>;
  switch (error.keyword) {
    case 'additionalProperties':
      return `${fieldPath(error.instancePath, String(params.additionalProperty))}: field not allowed by the contract`;
    case 'required':
      return `${fieldPath(error.instancePath, String(params.missingProperty))}: required field is missing`;
    case 'type':
      return `${fieldPath(error.instancePath)}: must be of type ${params.type}`;
    case 'enum':
      return `${fieldPath(error.instancePath)}: value is not one of ${JSON.stringify(params.allowedValues)}`;
    case 'const':
      return `${fieldPath(error.instancePath)}: must be ${JSON.stringify(params.allowedValue)}`;
    default:
      return `${fieldPath(error.instancePath)}: ${error.message}`;
  }
}

// Returns the list of contract violations. An empty list means the response follows the contract.
export function contractViolations(contract: string, body: unknown): string[] {
  const validate = ajv.getSchema(contract);
  if (!validate) throw new Error(`Unknown contract: "${contract}". See the contracts/ folder.`);
  return validate(body) ? [] : (validate.errors ?? []).map(describe);
}
