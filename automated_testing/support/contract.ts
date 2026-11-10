// Validação de contrato: compara a resposta da API com os JSON Schemas da pasta contracts/.
import { readdirSync, readFileSync } from 'node:fs';
import path from 'node:path';
import Ajv, { ErrorObject } from 'ajv';
import addFormats from 'ajv-formats';

const CONTRACTS_DIR = path.join(__dirname, '..', 'contracts');

const ajv = new Ajv({ allErrors: true, strict: true });
addFormats(ajv);

// Cada arquivo <nome>.schema.json fica disponível pelo seu $id, que é o próprio nome.
for (const file of readdirSync(CONTRACTS_DIR).filter((name) => name.endsWith('.schema.json'))) {
  ajv.addSchema(JSON.parse(readFileSync(path.join(CONTRACTS_DIR, file), 'utf8')));
}

// "/0/products/1/name" vira "[0].products[1].name", para facilitar a leitura do erro.
function fieldPath(instancePath: string, property?: string): string {
  const parts = [...instancePath.split('/').filter(Boolean), ...(property ? [property] : [])];
  const text = parts.map((part) => (/^\d+$/.test(part) ? `[${part}]` : `.${part}`)).join('');
  return text ? text.replace(/^\./, '') : '(raiz)';
}

function describe(error: ErrorObject): string {
  const params = error.params as Record<string, unknown>;
  switch (error.keyword) {
    case 'additionalProperties':
      return `${fieldPath(error.instancePath, String(params.additionalProperty))}: campo não previsto no contrato`;
    case 'required':
      return `${fieldPath(error.instancePath, String(params.missingProperty))}: campo obrigatório ausente`;
    case 'type':
      return `${fieldPath(error.instancePath)}: deve ser do tipo ${params.type}`;
    case 'enum':
      return `${fieldPath(error.instancePath)}: valor fora da lista ${JSON.stringify(params.allowedValues)}`;
    case 'const':
      return `${fieldPath(error.instancePath)}: deve ser ${JSON.stringify(params.allowedValue)}`;
    default:
      return `${fieldPath(error.instancePath)}: ${error.message}`;
  }
}

// Retorna a lista de violações do contrato. Lista vazia significa que a resposta segue o contrato.
export function contractViolations(contract: string, body: unknown): string[] {
  const validate = ajv.getSchema(contract);
  if (!validate) throw new Error(`Contrato desconhecido: "${contract}". Veja a pasta contracts/.`);
  return validate(body) ? [] : (validate.errors ?? []).map(describe);
}
