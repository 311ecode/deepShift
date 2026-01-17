/**
 * deepShift.test.js
 * entry point for deepShift node tests.
 */
const { describe } = require('node:test');

// Import individual test suites
require('./unit/testHandleRedundantExtensions.js');
require('./unit/testBasicRenaming.js');

// This file acts as a manifest for the Node.js test runner
// Run with: node --test src/deepShift/deepShift.test.js
