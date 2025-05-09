module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  parser: "@typescript-eslint/parser",
  ignorePatterns: [
    "/lib/**/*",
    "node_modules"
  ],
  rules: {
    "max-len": ["error", { "code": 120 }],
    "@typescript-eslint/no-unused-vars": "warn"
  }
};