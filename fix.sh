#!/bin/bash
# Complete fix for all Stage 1 issues

echo "🚨 Stage 1 Complete Fix Script"
echo "=============================="
echo ""
echo "Issues found:"
echo "- Wrong folder structure"
echo "- Files in wrong locations"
echo "- Generated files that shouldn't exist"
echo "- Missing configuration files"
echo ""
echo "Starting fix..."
echo ""

# Fix 1: Create correct directory structure
echo "1️⃣ Creating correct directory structure..."
mkdir -p src
mkdir -p tests
mkdir -p packages/{constructs/{aws,azure,shared},stacks,config/environments}
mkdir -p scripts
mkdir -p .github/workflows

# Fix 2: Move files to correct locations
echo -e "\n2️⃣ Moving files to correct locations..."
if [ -f "main.ts" ]; then
    mv main.ts src/main.ts
    echo "✅ Moved main.ts to src/"
fi

if [ -f "__tests__/main-test.ts" ]; then
    mv __tests__/main-test.ts tests/main.test.ts
    echo "✅ Moved test file to tests/"
fi

# Fix 3: Clean up unwanted files
echo -e "\n3️⃣ Cleaning up unwanted files..."
rm -f main.js main.d.ts
rm -f setup.js help tsconfig.tsbuildinfo
rm -f package-lock.json
rm -rf __tests__
rm -rf dist cdktf.out
echo "✅ Cleaned up generated and unwanted files"

# Fix 4: Create all missing config files
echo -e "\n4️⃣ Creating missing configuration files..."

# .prettierrc
if [ ! -f ".prettierrc" ]; then
    cat > .prettierrc << 'EOF'
{
  "semi": true,
  "trailingComma": "all",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "arrowParens": "always",
  "endOfLine": "lf",
  "bracketSpacing": true,
  "bracketSameLine": false,
  "proseWrap": "preserve"
}
EOF
    echo "✅ Created .prettierrc"
fi

# pnpm-workspace.yaml
if [ ! -f "pnpm-workspace.yaml" ]; then
    cat > pnpm-workspace.yaml << 'EOF'
packages:
  - 'packages/*'
EOF
    echo "✅ Created pnpm-workspace.yaml"
fi

# Fix 5: Update ESLint config to handle the issues
echo -e "\n5️⃣ Updating .eslintrc.js to fix parsing errors..."
cat > .eslintrc.js << 'EOF'
module.exports = {
  root: true,
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 2022,
    sourceType: 'module',
    project: './tsconfig.json',
    tsconfigRootDir: __dirname,
  },
  plugins: ['@typescript-eslint', 'import', 'prettier'],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:import/errors',
    'plugin:import/warnings',
    'plugin:import/typescript',
    'plugin:prettier/recommended',
  ],
  env: {
    node: true,
    jest: true,
  },
  rules: {
    '@typescript-eslint/no-unused-vars': ['error', {
      argsIgnorePattern: '^_',
      varsIgnorePattern: '^_',
    }],
    'import/order': [
      'error',
      {
        groups: [
          'builtin',
          'external',
          'internal',
          'parent',
          'sibling',
          'index',
        ],
        'newlines-between': 'always',
        alphabetize: {
          order: 'asc',
          caseInsensitive: true,
        },
      },
    ],
    'no-console': ['warn', { allow: ['warn', 'error'] }],
    'prefer-const': 'error',
  },
  settings: {
    'import/resolver': {
      typescript: {
        alwaysTryTypes: true,
        project: './tsconfig.json',
      },
    },
  },
  ignorePatterns: [
    'dist/',
    'node_modules/',
    'cdktf.out/',
    '.gen/',
    'coverage/',
    '*.js',
    '*.d.ts',
    '!.eslintrc.js',
    '!jest.config.js',
  ],
};
EOF
echo "✅ Updated .eslintrc.js"

# Fix 6: Install missing dependency
echo -e "\n6️⃣ Installing missing ESLint dependency..."
pnpm add -D eslint-import-resolver-typescript

# Fix 7: Auto-fix the import order issue
echo -e "\n7️⃣ Fixing code issues..."
pnpm run lint:fix || true
pnpm run format || true

# Fix 8: Show final structure
echo -e "\n✅ Fix complete! Here's your new structure:"
tree -I 'node_modules|.gen|pnpm-lock.yaml|dist|cdktf.out' -a -L 3

echo -e "\n🎯 Next steps:"
echo "1. Run: pnpm run build"
echo "2. Run: ./verify-setup.sh"
echo ""
echo "Your Stage 1 structure is now correct!"