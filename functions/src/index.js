"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ivr = exports.welcome = void 0;
// functions/src/index.ts
var admin = require("firebase-admin");
var https_1 = require("firebase-functions/v2/https");
var qs_1 = require("qs");
var twilio_1 = require("twilio");
var ivr_options_1 = require("./ivr-options");
admin.initializeApp();
var db = admin.firestore();
function normalizeParsedBody(parsed) {
    var normalized = {};
    for (var _i = 0, _a = Object.entries(parsed); _i < _a.length; _i++) {
        var _b = _a[_i], key = _b[0], rawValue = _b[1];
        if (Array.isArray(rawValue)) {
            normalized[key] =
                rawValue.length > 0 && rawValue[0] != null
                    ? String(rawValue[0])
                    : '';
        }
        else if (rawValue === undefined || rawValue === null) {
            normalized[key] = '';
        }
        else {
            normalized[key] = String(rawValue);
        }
    }
    return normalized;
}
function parseTwilioBody(req) {
    var _a;
    if (req.body && typeof req.body === 'object' && !Buffer.isBuffer(req.body)) {
        return normalizeParsedBody(req.body);
    }
    var rawBody = req.rawBody instanceof Buffer
        ? req.rawBody.toString('utf8')
        : String((_a = req.body) !== null && _a !== void 0 ? _a : '');
    var parsed = qs_1.default.parse(rawBody);
    return normalizeParsedBody(parsed);
}
function getRequestBaseUrl(req) {
    var _a, _b, _c;
    var protocol = (_c = (_b = (_a = req.headers['x-forwarded-proto']) === null || _a === void 0 ? void 0 : _a.split(',')[0]) !== null && _b !== void 0 ? _b : req.protocol) !== null && _c !== void 0 ? _c : 'https';
    var host = req.get('host');
    return "".concat(protocol, "://").concat(host);
}
function isValidTwilioSignature(req, params) {
    var authToken = process.env.TWILIO_AUTH_TOKEN;
    if (!authToken || authToken.trim().length === 0) {
        https_1.logger.warn('TWILIO_AUTH_TOKEN not configured. Skipping signature validation.');
        return true;
    }
    var signatureHeader = req.get('x-twilio-signature');
    if (!signatureHeader) {
        https_1.logger.error('Missing X-Twilio-Signature header.');
        return false;
    }
    var requestUrl = "".concat(getRequestBaseUrl(req)).concat(req.originalUrl);
    return twilio_1.default.validateRequest(authToken, signatureHeader, requestUrl, params);
}
function persistCallRecord(payload, optionLabel, isValid) {
    return __awaiter(this, void 0, void 0, function () {
        var _a, _b, _c, _d, _e, _f, _g;
        return __generator(this, function (_h) {
            switch (_h.label) {
                case 0: return [4 /*yield*/, db.collection('ivr_call_logs').add({
                        callSid: (_a = payload.CallSid) !== null && _a !== void 0 ? _a : null,
                        from: (_b = payload.From) !== null && _b !== void 0 ? _b : null,
                        to: (_c = payload.To) !== null && _c !== void 0 ? _c : null,
                        optionDigit: (_d = payload.Digits) !== null && _d !== void 0 ? _d : null,
                        optionLabel: optionLabel,
                        isValidSelection: isValid,
                        callerCity: (_e = payload.CallerCity) !== null && _e !== void 0 ? _e : null,
                        callerCountry: (_f = payload.CallerCountry) !== null && _f !== void 0 ? _f : null,
                        callerState: (_g = payload.CallerState) !== null && _g !== void 0 ? _g : null,
                        rawPayload: payload,
                        createdAt: admin.firestore.FieldValue.serverTimestamp(),
                    })];
                case 1:
                    _h.sent();
                    return [2 /*return*/];
            }
        });
    });
}
exports.welcome = (0, https_1.onRequest)({
    region: 'us-central1',
    timeoutSeconds: 15,
    cors: false,
}, function (req, res) { return __awaiter(void 0, void 0, void 0, function () {
    var response, gather;
    return __generator(this, function (_a) {
        if (req.method !== 'POST' && req.method !== 'GET') {
            res.status(405).send('Method Not Allowed');
            return [2 /*return*/];
        }
        response = new twilio_1.twiml.VoiceResponse();
        gather = response.gather({
            input: ['dtmf'],
            numDigits: 1,
            timeout: 5,
            action: "".concat(getRequestBaseUrl(req), "/ivr"),
            method: 'POST',
        });
        gather.say({
            voice: 'Polly.Joanna',
            language: 'en-US',
        }, (0, ivr_options_1.buildGatherPrompt)());
        response.say({
            voice: 'Polly.Joanna',
            language: 'en-US',
        }, 'We did not receive any input. Redirecting you to the main menu.');
        response.redirect("".concat(getRequestBaseUrl(req), "/welcome"));
        res.set('Content-Type', 'text/xml');
        res.status(200).send(response.toString());
        return [2 /*return*/];
    });
}); });
exports.ivr = (0, https_1.onRequest)({
    region: 'us-central1',
    timeoutSeconds: 15,
    cors: false,
}, function (req, res) { return __awaiter(void 0, void 0, void 0, function () {
    var twilioRequest, payload, response, ivrOption, optionLabel, isValidSelection, error_1;
    var _a;
    return __generator(this, function (_b) {
        switch (_b.label) {
            case 0:
                if (req.method !== 'POST') {
                    res.status(405).send('Method Not Allowed');
                    return [2 /*return*/];
                }
                twilioRequest = req;
                payload = parseTwilioBody(twilioRequest);
                if (!isValidTwilioSignature(twilioRequest, payload)) {
                    https_1.logger.error('Invalid Twilio signature detected.');
                    res.status(403).send('Invalid signature.');
                    return [2 /*return*/];
                }
                response = new twilio_1.twiml.VoiceResponse();
                _b.label = 1;
            case 1:
                _b.trys.push([1, 3, , 4]);
                ivrOption = (0, ivr_options_1.resolveIvrOption)(payload.Digits);
                optionLabel = (_a = ivrOption === null || ivrOption === void 0 ? void 0 : ivrOption.label) !== null && _a !== void 0 ? _a : 'Unknown Selection';
                isValidSelection = ivrOption != null;
                return [4 /*yield*/, persistCallRecord(payload, optionLabel, isValidSelection)];
            case 2:
                _b.sent();
                https_1.logger.info('Persisted IVR call record', {
                    callSid: payload.CallSid,
                    optionDigit: payload.Digits,
                    optionLabel: optionLabel,
                    from: payload.From,
                });
                if (ivrOption) {
                    response.say({
                        voice: 'Polly.Joanna',
                        language: 'en-US',
                    }, ivrOption.completionMessage);
                    response.hangup();
                }
                else {
                    response.say({
                        voice: 'Polly.Joanna',
                        language: 'en-US',
                    }, 'We did not recognize that selection. Please try again.');
                    response.redirect("".concat(getRequestBaseUrl(req), "/welcome"));
                }
                res.set('Content-Type', 'text/xml');
                res.status(200).send(response.toString());
                return [3 /*break*/, 4];
            case 3:
                error_1 = _b.sent();
                https_1.logger.error('Failed to handle IVR selection.', error_1);
                response.say({
                    voice: 'Polly.Joanna',
                    language: 'en-US',
                }, 'We are experiencing technical difficulties. Please try again later.');
                res.set('Content-Type', 'text/xml');
                res.status(500).send(response.toString());
                return [3 /*break*/, 4];
            case 4: return [2 /*return*/];
        }
    });
}); });
