#!/usr/bin/env node
import fs from 'node:fs';

const policyPath = 'config/dependency-policy.json';
const reportPath = 'dependency-report.json';

if (!fs.existsSync(policyPath)) {
  console.error('Missing dependency policy file:', policyPath);
  process.exit(1);
}

const policy = JSON.parse(fs.readFileSync(policyPath, 'utf8'));

const reportExists = fs.existsSync(reportPath);
if (!reportExists) {
  console.log('No dependency-report.json found. Phase 0 baseline pass (no locked third-party dependencies yet).');
  process.exit(0);
}

const report = JSON.parse(fs.readFileSync(reportPath, 'utf8'));
const denied = new Set(policy.deniedLicenses);
const unknown = [];
const blocked = [];

for (const dep of report.dependencies ?? []) {
  const license = dep.license;
  if (!license) {
    unknown.push(dep.name);
    continue;
  }
  if (denied.has(license)) {
    blocked.push(`${dep.name}@${dep.version} (${license})`);
  }
}

if (unknown.length > 0) {
  console.error('Dependencies missing license metadata:', unknown.join(', '));
  process.exit(1);
}

if (blocked.length > 0) {
  console.error('Blocked licenses found:');
  for (const b of blocked) console.error(' -', b);
  process.exit(1);
}

console.log('Dependency policy check passed.');
