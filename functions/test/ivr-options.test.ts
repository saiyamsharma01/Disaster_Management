// functions/test/ivr-options.test.ts
import { describe, expect, it } from 'vitest';
import { buildGatherPrompt, resolveIvrOption } from '../src/ivr-options';

describe('resolveIvrOption', () => {
  it('returns the correct option when digit matches', () => {
    const option = resolveIvrOption('1');
    expect(option).not.toBeNull();
    expect(option?.label).toBe('Emergency Response');
  });

  it('returns null for unsupported digits', () => {
    const option = resolveIvrOption('9');
    expect(option).toBeNull();
  });

  it('handles whitespace and null values safely', () => {
    expect(resolveIvrOption(' 2 ')).not.toBeNull();
    expect(resolveIvrOption(null)).toBeNull();
    expect(resolveIvrOption(undefined)).toBeNull();
  });
});

describe('buildGatherPrompt', () => {
  it('includes all options in the prompt', () => {
    const prompt = buildGatherPrompt();
    expect(prompt).toContain('Press 1');
    expect(prompt).toContain('Press 2');
    expect(prompt).toContain('Press 3');
  });
});
