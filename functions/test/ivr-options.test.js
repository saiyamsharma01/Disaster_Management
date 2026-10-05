"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// functions/test/ivr-options.test.ts
const vitest_1 = require("vitest");
const ivr_options_1 = require("../src/ivr-options");
(0, vitest_1.describe)('resolveIvrOption', () => {
    (0, vitest_1.it)('returns the correct option when digit matches', () => {
        const option = (0, ivr_options_1.resolveIvrOption)('1');
        (0, vitest_1.expect)(option).not.toBeNull();
        (0, vitest_1.expect)(option?.label).toBe('Emergency Response');
    });
    (0, vitest_1.it)('returns null for unsupported digits', () => {
        const option = (0, ivr_options_1.resolveIvrOption)('9');
        (0, vitest_1.expect)(option).toBeNull();
    });
    (0, vitest_1.it)('handles whitespace and null values safely', () => {
        (0, vitest_1.expect)((0, ivr_options_1.resolveIvrOption)(' 2 ')).not.toBeNull();
        (0, vitest_1.expect)((0, ivr_options_1.resolveIvrOption)(null)).toBeNull();
        (0, vitest_1.expect)((0, ivr_options_1.resolveIvrOption)(undefined)).toBeNull();
    });
});
(0, vitest_1.describe)('buildGatherPrompt', () => {
    (0, vitest_1.it)('includes all options in the prompt', () => {
        const prompt = (0, ivr_options_1.buildGatherPrompt)();
        (0, vitest_1.expect)(prompt).toContain('Press 1');
        (0, vitest_1.expect)(prompt).toContain('Press 2');
        (0, vitest_1.expect)(prompt).toContain('Press 3');
    });
});
