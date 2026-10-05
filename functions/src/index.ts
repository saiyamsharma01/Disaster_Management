// functions/src/index.ts
import * as admin from 'firebase-admin';
import { logger, onRequest } from 'firebase-functions/v2/https';
import { Request } from 'express';
import qs, { ParsedQs } from 'qs';
import twilio, { twiml } from 'twilio';
import { buildGatherPrompt, resolveIvrOption } from './ivr-options';

// Export flood alert functions
export {
  storeFCMToken,
  createFloodAlert,
  sendEvacuationAlert,
  sendWeatherWarning,
  getFloodAlerts,
} from './flood-alerts';

admin.initializeApp();
const db = admin.firestore();

type TwilioHttpRequest = Request & { rawBody: Buffer };

interface NormalizedTwilioPayload {
  [key: string]: string;
}

function normalizeParsedBody(
  parsed: ParsedQs | Record<string, unknown>,
): NormalizedTwilioPayload {
  const normalized: NormalizedTwilioPayload = {};
  for (const [key, rawValue] of Object.entries(parsed)) {
    if (Array.isArray(rawValue)) {
      normalized[key] =
        rawValue.length > 0 && rawValue[0] != null
          ? String(rawValue[0])
          : '';
    } else if (rawValue === undefined || rawValue === null) {
      normalized[key] = '';
    } else {
      normalized[key] = String(rawValue);
    }
  }
  return normalized;
}

function parseTwilioBody(req: TwilioHttpRequest): NormalizedTwilioPayload {
  if (req.body && typeof req.body === 'object' && !Buffer.isBuffer(req.body)) {
    return normalizeParsedBody(req.body as Record<string, unknown>);
  }

  const rawBody =
    req.rawBody instanceof Buffer
      ? req.rawBody.toString('utf8')
      : String(req.body ?? '');
  const parsed = qs.parse(rawBody);
  return normalizeParsedBody(parsed);
}

function getRequestBaseUrl(req: Request): string {
  const protocol =
    (req.headers['x-forwarded-proto'] as string | undefined)?.split(',')[0] ??
    req.protocol ??
    'https';
  const host = req.get('host');
  return `${protocol}://${host}`;
}

function isValidTwilioSignature(
  req: TwilioHttpRequest,
  params: NormalizedTwilioPayload,
): boolean {
  const authToken = process.env.TWILIO_AUTH_TOKEN;
  if (!authToken || authToken.trim().length === 0) {
    logger.warn(
      'TWILIO_AUTH_TOKEN not configured. Skipping signature validation.',
    );
    return true;
  }

  const signatureHeader = req.get('x-twilio-signature');
  if (!signatureHeader) {
    logger.error('Missing X-Twilio-Signature header.');
    return false;
  }

  const requestUrl = `${getRequestBaseUrl(req)}${req.originalUrl}`;
  return twilio.validateRequest(authToken, signatureHeader, requestUrl, params);
}

async function persistCallRecord(
  payload: NormalizedTwilioPayload,
  optionLabel: string,
  isValid: boolean,
): Promise<void> {
  await db.collection('ivr_call_logs').add({
    callSid: payload.CallSid ?? null,
    from: payload.From ?? null,
    to: payload.To ?? null,
    optionDigit: payload.Digits ?? null,
    optionLabel,
    isValidSelection: isValid,
    callerCity: payload.CallerCity ?? null,
    callerCountry: payload.CallerCountry ?? null,
    callerState: payload.CallerState ?? null,
    rawPayload: payload,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

export const welcome = onRequest(
  {
    region: 'us-central1',
    timeoutSeconds: 15,
    cors: false,
  },
  async (req, res) => {
    if (req.method !== 'POST' && req.method !== 'GET') {
      res.status(405).send('Method Not Allowed');
      return;
    }

    const response = new twiml.VoiceResponse();
    const gather = response.gather({
      input: ['dtmf'],
      numDigits: 1,
      timeout: 5,
      action: `${getRequestBaseUrl(req)}/ivr`,
      method: 'POST',
    });

    gather.say(
      {
        voice: 'Polly.Joanna',
        language: 'en-US',
      },
      buildGatherPrompt(),
    );

    response.say(
      {
        voice: 'Polly.Joanna',
        language: 'en-US',
      },
      'We did not receive any input. Redirecting you to the main menu.',
    );
    response.redirect(`${getRequestBaseUrl(req)}/welcome`);

    res.set('Content-Type', 'text/xml');
    res.status(200).send(response.toString());
  },
);

export const ivr = onRequest(
  {
    region: 'us-central1',
    timeoutSeconds: 15,
    cors: false,
  },
  async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).send('Method Not Allowed');
      return;
    }

    const twilioRequest = req as TwilioHttpRequest;
    const payload = parseTwilioBody(twilioRequest);

    if (!isValidTwilioSignature(twilioRequest, payload)) {
      logger.error('Invalid Twilio signature detected.');
      res.status(403).send('Invalid signature.');
      return;
    }

    const response = new twiml.VoiceResponse();
    try {
      const ivrOption = resolveIvrOption(payload.Digits);
      const optionLabel = ivrOption?.label ?? 'Unknown Selection';
      const isValidSelection = ivrOption != null;

      await persistCallRecord(payload, optionLabel, isValidSelection);
      logger.info('Persisted IVR call record', {
        callSid: payload.CallSid,
        optionDigit: payload.Digits,
        optionLabel,
        from: payload.From,
      });

      if (ivrOption) {
        response.say(
          {
            voice: 'Polly.Joanna',
            language: 'en-US',
          },
          ivrOption.completionMessage,
        );
        response.hangup();
      } else {
        response.say(
          {
            voice: 'Polly.Joanna',
            language: 'en-US',
          },
          'We did not recognize that selection. Please try again.',
        );
        response.redirect(`${getRequestBaseUrl(req)}/welcome`);
      }

      res.set('Content-Type', 'text/xml');
      res.status(200).send(response.toString());
    } catch (error) {
      logger.error('Failed to handle IVR selection.', error as Error);
      response.say(
        {
          voice: 'Polly.Joanna',
          language: 'en-US',
        },
        'We are experiencing technical difficulties. Please try again later.',
      );
      res.set('Content-Type', 'text/xml');
      res.status(500).send(response.toString());
    }
  },
);
