import typescriptEslint from "@typescript-eslint/eslint-plugin";
import typescriptParser from "@typescript-eslint/parser";
import jestPlugin from "eslint-plugin-jest";
import prettierPlugin from "eslint-plugin-prettier";
import prettierConfig from "eslint-config-prettier";

export default [
  {
    // Aplica estas configurações a arquivos TS
    files: ["src/**/*.ts", "test/**/*.ts"],
    languageOptions: {
      parser: typescriptParser,
      globals: {
        // Equivale ao "env": {"node": true}
        process: "readonly",
        console: "readonly",
      },
    },
    plugins: {
      "@typescript-eslint": typescriptEslint,
      jest: jestPlugin,
      prettier: prettierPlugin,
    },
    rules: {
      ...typescriptEslint.configs.recommended.rules,
      ...jestPlugin.configs.recommended.rules,
      ...prettierConfig.rules, // Desativa regras que conflitam com Prettier
      "prettier/prettier": "error",
      "@typescript-eslint/no-unused-vars": "warn",
    },
  },
  {
    // Configuração específica para os arquivos de teste
    files: ["test/**/*.ts", "**/*.test.ts"],
    languageOptions: {
      globals: {
        ...jestPlugin.environments.globals.globals,
      },
    },
  },
];
