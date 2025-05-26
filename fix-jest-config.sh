#!/bin/bash
# Fix Jest configuration

echo "🔧 Fixing Jest Configuration"
echo "==========================="

echo "Current jest.config.js has setupFilesAfterEnv pointing to non-existent setup.js"
echo ""

# Backup current config
cp jest.config.js jest.config.js.backup

# Create correct jest.config.js for Stage 1
cat > jest.config.js << 'EOF'
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src', '<rootDir>/packages', '<rootDir>/tests'],
  testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
  transform: {
    '^.+\\.ts$': 'ts-jest',
  },
  collectCoverageFrom: [
    'src/**/*.ts',
    'packages/**/*.ts',
    '!**/*.d.ts',
    '!**/node_modules/**',
    '!**/.gen/**',
    '!**/dist/**',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
  moduleNameMapper: {
    '^@constructs/(.*)$': '<rootDir>/packages/constructs/$1',
    '^@stacks/(.*)$': '<rootDir>/packages/stacks/$1',
    '^@config/(.*)$': '<rootDir>/packages/config/$1',
  },
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  globals: {
    'ts-jest': {
      tsconfig: {
        esModuleInterop: true,
      },
    },
  },
  testTimeout: 10000,
  clearMocks: true,
  restoreMocks: true,
};
EOF

echo "✅ Fixed jest.config.js"
echo ""
echo "Now running tests..."
pnpm test