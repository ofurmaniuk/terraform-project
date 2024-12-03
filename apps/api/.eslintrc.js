// .eslintrc.js
module.exports = {
    env: {
      node: true,
      es2021: true,
      commonjs: true,
    },
    extends: [
      'eslint:recommended',
      'plugin:prettier/recommended' // Enables eslint-plugin-prettier and eslint-config-prettier
    ],
    parserOptions: {
      ecmaVersion: 2021,
    },
    rules: {
      'prettier/prettier': [
        'error',
        {
          semi: true,
          trailingComma: 'all',
          singleQuote: true,
          printWidth: 80,
          tabWidth: 2,
          endOfLine: 'auto',
          arrowParens: 'avoid',
        }
      ],
      // Common JavaScript best practices
      'no-console': ['warn', { allow: ['warn', 'error'] }],
      'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      'no-var': 'error',
      'prefer-const': 'error',
      'arrow-body-style': ['error', 'as-needed'],
      'no-multiple-empty-lines': ['error', { max: 1, maxEOF: 0 }],
      'no-trailing-spaces': 'error',
      'object-curly-spacing': ['error', 'always'],
      'comma-dangle': ['error', 'always-multiline'],
      'eol-last': ['error', 'always'],
      // Node.js specific rules
      'callback-return': 'error',
      'handle-callback-err': 'error',
      'no-path-concat': 'error',
      'no-buffer-constructor': 'error',
      // ES6+ specific rules
      'arrow-spacing': 'error',
      'no-duplicate-imports': 'error',
      'template-curly-spacing': ['error', 'never'],
      // Express specific rules (since you're using Express)
      'no-mixed-requires': 'error',
      'no-new-require': 'error',
    },
    overrides: [
      {
        files: ['**/*.test.js', '**/*.spec.js'],
        env: {
          jest: true,
        },
        rules: {
          'no-console': 'off',
        },
      },
    ],
  };