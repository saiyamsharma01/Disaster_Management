"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.IVR_OPTIONS = void 0;
exports.resolveIvrOption = resolveIvrOption;
exports.buildGatherPrompt = buildGatherPrompt;
exports.IVR_OPTIONS = [
    {
        digit: '1',
        label: 'Emergency Response',
        completionMessage: 'Emergency services have been notified. Stay on the line if additional details are needed.',
    },
    {
        digit: '2',
        label: 'HIV/AIDS Support',
        completionMessage: 'A health specialist will reach out to you with confidential support shortly.',
    },
    {
        digit: '3',
        label: 'Volunteer Coordination',
        completionMessage: 'Our volunteer coordinator will contact you with the next available opportunities.',
    },
];
function resolveIvrOption(digit) {
    var _a;
    if (!digit) {
        return null;
    }
    return ((_a = exports.IVR_OPTIONS.find(function (option) { return option.digit.trim() == digit.trim(); })) !== null && _a !== void 0 ? _a : null);
}
function buildGatherPrompt() {
    return exports.IVR_OPTIONS.map(function (option) { return "Press ".concat(option.digit, " for ").concat(option.label, "."); }).join(' ');
}
