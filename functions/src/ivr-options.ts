// functions/src/ivr-options.ts
export interface IvrOption {
  digit: string;
  label: string;
  completionMessage: string;
}

export const IVR_OPTIONS: ReadonlyArray<IvrOption> = [
  {
    digit: '1',
    label: 'Emergency Response',
    completionMessage:
      'Emergency services have been notified. Stay on the line if additional details are needed.',
  },
  {
    digit: '2',
    label: 'HIV/AIDS Support',
    completionMessage:
      'A health specialist will reach out to you with confidential support shortly.',
  },
  {
    digit: '3',
    label: 'Volunteer Coordination',
    completionMessage:
      'Our volunteer coordinator will contact you with the next available opportunities.',
  },
];

export function resolveIvrOption(
  digit: string | null | undefined,
): IvrOption | null {
  if (!digit) {
    return null;
  }

  return (
    IVR_OPTIONS.find(
      (option) => option.digit.trim() == digit.trim(),
    ) ?? null
  );
}

export function buildGatherPrompt(): string {
  return IVR_OPTIONS.map(
    (option) => `Press ${option.digit} for ${option.label}.`,
  ).join(' ');
}
