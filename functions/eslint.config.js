const tseslint = require("@typescript-eslint/eslint-plugin");
const tsParser = require("@typescript-eslint/parser");
const {FlatCompat} = require("@eslint/eslintrc");

const compat = new FlatCompat({
  baseDirectory: __dirname,
  resolvePluginsRelativeTo: __dirname,
});

module.exports = [
  {
    ignores: ["lib/**/*", "generated/**/*"],
  },
  ...compat.extends("eslint:recommended"),
  ...compat.extends("plugin:import/errors"),
  ...compat.extends("plugin:import/warnings"),
  ...compat.extends("plugin:import/typescript"),
  ...compat.extends("google"),
  ...compat.extends("plugin:@typescript-eslint/recommended"),
  {
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        project: ["tsconfig.json", "tsconfig.dev.json"],
        sourceType: "module",
      },
    },
    plugins: {
      "@typescript-eslint": tseslint,
    },
    rules: {
      quotes: ["error", "double"],
      "import/no-unresolved": 0,
      indent: ["error", 2],
    },
  },
];