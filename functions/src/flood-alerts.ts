// functions/src/flood-alerts.ts
import * as admin from 'firebase-admin';
import { logger, onRequest } from 'firebase-functions/v2/https';
import { Request, Response } from 'express';
import * as cors from 'cors';

const corsHandler = cors({ origin: true });

// Types for flood alert data
interface FloodAlert {
  id?: string;
  location: string;
  severity: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  waterLevel: number;
  status: string;
  description?: string;
  coordinates?: {
    latitude: number;
    longitude: number;
  };
  timestamp: admin.firestore.Timestamp;
  isActive: boolean;
}

interface FCMToken {
  token: string;
  userId: string;
  deviceType: 'android' | 'ios' | 'web';
  lastUpdated: admin.firestore.Timestamp;
  isActive: boolean;
}

interface NotificationPayload {
  title: string;
  body: string;
  data: {
    type: 'flood_alert' | 'evacuation' | 'weather_warning';
    alertId: string;
    location: string;
    severity: string;
    [key: string]: string;
  };
}

// Store FCM token
export const storeFCMToken = onRequest(
  {
    region: 'us-central1',
    timeoutSeconds: 15,
    cors: true,
  },
  async (req: Request, res: Response) => {
    return corsHandler(req, res, async () => {
      if (req.method !== 'POST') {
        res.status(405).json({ error: 'Method Not Allowed' });
        return;
      }

      try {
        const { token, userId, deviceType = 'web' } = req.body;

        if (!token || !userId) {
          res.status(400).json({ error: 'Token and userId are required' });
          return;
        }

        // Store or update FCM token
        await admin.firestore().collection('fcm_tokens').doc(userId).set({
          token,
          userId,
          deviceType,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          isActive: true,
        });

        logger.info('FCM token stored successfully', { userId, deviceType });
        res.status(200).json({ success: true, message: 'FCM token stored successfully' });
      } catch (error) {
        logger.error('Error storing FCM token:', error);
        res.status(500).json({ error: 'Internal server error' });
      }
    });
  },
);

// Create flood alert
export const createFloodAlert = onRequest(
  {
    region: 'us-central1',
    timeoutSeconds: 30,
    cors: true,
  },
  async (req: Request, res: Response) => {
    return corsHandler(req, res, async () => {
      if (req.method !== 'POST') {
        res.status(405).json({ error: 'Method Not Allowed' });
        return;
      }

      try {
        const alertData: Omit<FloodAlert, 'id' | 'timestamp'> = {
          location: req.body.location,
          severity: req.body.severity,
          waterLevel: req.body.waterLevel,
          status: req.body.status,
          description: req.body.description,
          coordinates: req.body.coordinates,
          isActive: true,
        };

        // Validate required fields
        if (!alertData.location || !alertData.severity || alertData.waterLevel === undefined) {
          res.status(400).json({ error: 'Missing required fields: location, severity, waterLevel' });
          return;
        }

        // Add timestamp
        const alert: FloodAlert = {
          ...alertData,
          timestamp: admin.firestore.FieldValue.serverTimestamp() as admin.firestore.Timestamp,
        };

        // Store alert in Firestore
        const docRef = await admin.firestore().collection('flood_alerts').add(alert);
        const alertId = docRef.id;

        // Send notifications to all active FCM tokens
        await sendFloodAlertNotifications(alertId, alert);

        logger.info('Flood alert created and notifications sent', { alertId, location: alert.location });
        res.status(201).json({ 
          success: true, 
          alertId,
          message: 'Flood alert created and notifications sent successfully' 
        });
      } catch (error) {
        logger.error('Error creating flood alert:', error);
        res.status(500).json({ error: 'Internal server error' });
      }
    });
  },
);

// Send flood alert notifications
async function sendFloodAlertNotifications(alertId: string, alert: FloodAlert): Promise<void> {
  try {
    // Get all active FCM tokens
    const tokensSnapshot = await admin.firestore()
      .collection('fcm_tokens')
      .where('isActive', '==', true)
      .get();

    if (tokensSnapshot.empty) {
      logger.warn('No active FCM tokens found for flood alert notifications');
      return;
    }

    const tokens = tokensSnapshot.docs.map(doc => doc.data() as FCMToken);
    const fcmTokens = tokens.map(token => token.token);

    // Create notification payload
    const payload: NotificationPayload = {
      title: `🌊 Flood Alert - ${alert.location}`,
      body: `Severity: ${alert.severity} | Water Level: ${alert.waterLevel}m | ${alert.status}`,
      data: {
        type: 'flood_alert',
        alertId,
        location: alert.location,
        severity: alert.severity,
        waterLevel: alert.waterLevel.toString(),
        status: alert.status,
        description: alert.description || '',
      },
    };

    // Send to all tokens
    const message: admin.messaging.MulticastMessage = {
      notification: {
        title: payload.title,
        body: payload.body,
      },
      data: payload.data,
      tokens: fcmTokens,
      android: {
        priority: 'high',
        notification: {
          icon: 'ic_launcher',
          color: getSeverityColor(alert.severity),
          sound: 'default',
          channelId: 'flood_alerts',
        },
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title: payload.title,
              body: payload.body,
            },
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    const response = await admin.messaging().sendMulticast(message);
    
    logger.info('Flood alert notifications sent', {
      successCount: response.successCount,
      failureCount: response.failureCount,
      alertId,
    });

    // Handle failed tokens
    if (response.failureCount > 0) {
      const failedTokens: string[] = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          failedTokens.push(fcmTokens[idx]);
          logger.error('Failed to send notification to token:', {
            token: fcmTokens[idx],
            error: resp.error,
          });
        }
      });

      // Mark failed tokens as inactive
      if (failedTokens.length > 0) {
        await deactivateFailedTokens(failedTokens);
      }
    }
  } catch (error) {
    logger.error('Error sending flood alert notifications:', error);
    throw error;
  }
}

// Send evacuation alert
export const sendEvacuationAlert = onRequest(
  {
    region: 'us-central1',
    timeoutSeconds: 30,
    cors: true,
  },
  async (req: Request, res: Response) => {
    return corsHandler(req, res, async () => {
      if (req.method !== 'POST') {
        res.status(405).json({ error: 'Method Not Allowed' });
        return;
      }

      try {
        const { location, evacuationCenter, description } = req.body;

        if (!location || !evacuationCenter) {
          res.status(400).json({ error: 'Location and evacuation center are required' });
          return;
        }

        // Get all active FCM tokens
        const tokensSnapshot = await admin.firestore()
          .collection('fcm_tokens')
          .where('isActive', '==', true)
          .get();

        if (tokensSnapshot.empty) {
          res.status(404).json({ error: 'No active FCM tokens found' });
          return;
        }

        const tokens = tokensSnapshot.docs.map(doc => doc.data() as FCMToken);
        const fcmTokens = tokens.map(token => token.token);

        const message: admin.messaging.MulticastMessage = {
          notification: {
            title: '🚨 EVACUATION ALERT',
            body: `Immediate evacuation required in ${location}. Evacuation Center: ${evacuationCenter}`,
          },
          data: {
            type: 'evacuation',
            location,
            evacuationCenter,
            description: description || '',
          },
          tokens: fcmTokens,
          android: {
            priority: 'high',
            notification: {
              icon: 'ic_launcher',
              color: '#FF0000',
              sound: 'default',
              channelId: 'flood_alerts',
            },
          },
          apns: {
            payload: {
              aps: {
                alert: {
                  title: '🚨 EVACUATION ALERT',
                  body: `Immediate evacuation required in ${location}. Evacuation Center: ${evacuationCenter}`,
                },
                sound: 'default',
                badge: 1,
              },
            },
          },
        };

        const response = await admin.messaging().sendMulticast(message);
        
        logger.info('Evacuation alert sent', {
          successCount: response.successCount,
          failureCount: response.failureCount,
          location,
        });

        res.status(200).json({ 
          success: true, 
          message: 'Evacuation alert sent successfully',
          successCount: response.successCount,
          failureCount: response.failureCount,
        });
      } catch (error) {
        logger.error('Error sending evacuation alert:', error);
        res.status(500).json({ error: 'Internal server error' });
      }
    });
  },
);

// Send weather warning
export const sendWeatherWarning = onRequest(
  {
    region: 'us-central1',
    timeoutSeconds: 30,
    cors: true,
  },
  async (req: Request, res: Response) => {
    return corsHandler(req, res, async () => {
      if (req.method !== 'POST') {
        res.status(405).json({ error: 'Method Not Allowed' });
        return;
      }

      try {
        const { warningType, location, duration, description } = req.body;

        if (!warningType || !location) {
          res.status(400).json({ error: 'Warning type and location are required' });
          return;
        }

        // Get all active FCM tokens
        const tokensSnapshot = await admin.firestore()
          .collection('fcm_tokens')
          .where('isActive', '==', true)
          .get();

        if (tokensSnapshot.empty) {
          res.status(404).json({ error: 'No active FCM tokens found' });
          return;
        }

        const tokens = tokensSnapshot.docs.map(doc => doc.data() as FCMToken);
        const fcmTokens = tokens.map(token => token.token);

        const message: admin.messaging.MulticastMessage = {
          notification: {
            title: `⚠️ Weather Warning - ${warningType}`,
            body: `Location: ${location}${duration ? ` | Duration: ${duration}` : ''}`,
          },
          data: {
            type: 'weather_warning',
            warningType,
            location,
            duration: duration || '',
            description: description || '',
          },
          tokens: fcmTokens,
          android: {
            priority: 'high',
            notification: {
              icon: 'ic_launcher',
              color: '#FFA500',
              sound: 'default',
              channelId: 'flood_alerts',
            },
          },
          apns: {
            payload: {
              aps: {
                alert: {
                  title: `⚠️ Weather Warning - ${warningType}`,
                  body: `Location: ${location}${duration ? ` | Duration: ${duration}` : ''}`,
                },
                sound: 'default',
                badge: 1,
              },
            },
          },
        };

        const response = await admin.messaging().sendMulticast(message);
        
        logger.info('Weather warning sent', {
          successCount: response.successCount,
          failureCount: response.failureCount,
          warningType,
          location,
        });

        res.status(200).json({ 
          success: true, 
          message: 'Weather warning sent successfully',
          successCount: response.successCount,
          failureCount: response.failureCount,
        });
      } catch (error) {
        logger.error('Error sending weather warning:', error);
        res.status(500).json({ error: 'Internal server error' });
      }
    });
  },
);

// Get active flood alerts
export const getFloodAlerts = onRequest(
  {
    region: 'us-central1',
    timeoutSeconds: 15,
    cors: true,
  },
  async (req: Request, res: Response) => {
    return corsHandler(req, res, async () => {
      if (req.method !== 'GET') {
        res.status(405).json({ error: 'Method Not Allowed' });
        return;
      }

      try {
        const { limit = '50', active = 'true' } = req.query;
        
        let query = admin.firestore().collection('flood_alerts');
        
        if (active === 'true') {
          query = query.where('isActive', '==', true);
        }
        
        query = query.orderBy('timestamp', 'desc').limit(parseInt(limit as string));

        const snapshot = await query.get();
        const alerts = snapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data(),
        }));

        res.status(200).json({ 
          success: true, 
          alerts,
          count: alerts.length,
        });
      } catch (error) {
        logger.error('Error fetching flood alerts:', error);
        res.status(500).json({ error: 'Internal server error' });
      }
    });
  },
);

// Helper function to get severity color
function getSeverityColor(severity: string): string {
  switch (severity) {
    case 'CRITICAL':
      return '#FF0000';
    case 'HIGH':
      return '#FF4500';
    case 'MEDIUM':
      return '#FFA500';
    case 'LOW':
      return '#FFFF00';
    default:
      return '#2196F3';
  }
}

// Helper function to deactivate failed tokens
async function deactivateFailedTokens(failedTokens: string[]): Promise<void> {
  const batch = admin.firestore().batch();
  
  for (const token of failedTokens) {
    const tokenQuery = await admin.firestore()
      .collection('fcm_tokens')
      .where('token', '==', token)
      .get();
    
    tokenQuery.docs.forEach(doc => {
      batch.update(doc.ref, { isActive: false });
    });
  }
  
  await batch.commit();
  logger.info('Deactivated failed FCM tokens', { count: failedTokens.length });
}
