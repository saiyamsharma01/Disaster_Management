"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// functions/vitest.config.ts
var config_1 = require("vitest/config");
exports.default = (0, config_1.defineConfig)({
    test: {
        globals: true,
        environment: 'node',
        coverage: {
            reporter: ['text', 'lcov'],
        },
    },
});
