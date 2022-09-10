module.exports = {
  env: {
    browser: false,
    es2021: true,
    mocha: true,
    node: true,
  },
  plugins: ['import', 'prefer-arrow'],
  extends: [
    'airbnb-base',
    'eslint:recommended',
    'plugin:import/typescript',
    'plugin:@typescript-eslint/recommended',
    'plugin:node/recommended',
    'prettier',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 12,
  },
  rules: {
    'node/no-missing-import': 'off',
    'no-unused-vars': 'off',
    'no-use-before-define': 'off',
    'no-undef': 'off',
    'no-console': 'off',
    'no-shadow': 'warn',
    'no-bitwise': 'warn',
    'import/extensions': [
      'error',
      'ignorePackages',
      {
        js: 'never',
        jsx: 'never',
        ts: 'never',
        tsx: 'never',
      },
    ],
    'prefer-arrow/prefer-arrow-functions': [
      'error',
      {
        disallowPrototype: true,
        singleReturnOnly: false,
        classPropertiesAllowed: false,
      },
    ],
    'node/no-unsupported-features/es-builtins': 'off',
    'node/no-unsupported-features/es-syntax': ['error', { ignores: ['modules'] }],
  },
};
