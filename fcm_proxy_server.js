// fcm_proxy_server.js
// Simple Node.js server to proxy FCM requests and avoid CORS issues

const express = require('express');
const cors = require('cors');
const axios = require('axios');
const { exec } = require('child_process');
const path = require('path');

const app = express();
const PORT = 3002; // Changed to 3002 to avoid conflicts

// FCM endpoint
const FCM_URL = 'https://fcm.googleapis.com/v1/projects/fir-tutorial-826a8/messages:send';

// Get fresh OAuth token
async function getOAuthToken() {
  return new Promise((resolve, reject) => {
    const dartScriptPath = path.resolve(__dirname, 'lib/serverkey.dart');
    
    exec(`dart ${dartScriptPath}`, (error, stdout, stderr) => {
      if (error) {
        console.error(`Error executing Dart script: ${error.message}`);
        reject(error);
        return;
      }
      
      if (stderr) {
        console.error(`Dart script stderr: ${stderr}`);
      }
      
      // Extract token from stdout
      const tokenMatch = stdout.match(/Token: (.*)/);
      if (tokenMatch && tokenMatch[1]) {
        resolve(tokenMatch[1].trim());
      } else {
        reject(new Error('Could not extract token from Dart script output'));
      }
    });
  });
}

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'FCM Proxy Server Running',
    status: 'OK'
  });
});

// Send FCM notification endpoint
app.post('/send-notification', async (req, res) => {
  try {
    const { token, title, body, data } = req.body;

    if (!token || !title || !body) {
      return res.status(400).json({
        success: false,
        error: 'Token, title and body are required'
      });
    }

    // Get fresh OAuth token
    const oauthToken = await getOAuthToken();
    
    // Format for FCM v1 API
    const payload = {
      message: {
        token: token,
        notification: {
          title: title,
          body: body
        },
        data: data || {},
        android: {
          notification: {
            icon: 'ic_launcher',
            sound: 'default',
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
          }
        },
        apns: {
          payload: {
            aps: {
              sound: 'default'
            }
          }
        },
        webpush: {
          notification: {
            icon: '/favicon.png'
          }
        }
      }
    };

    const response = await axios.post(FCM_URL, payload, {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${oauthToken}`
      }
    });

    console.log('✅ FCM notification sent successfully');
    res.json({
      success: true,
      message: 'Notification sent successfully',
      response: response.data
    });

  } catch (error) {
    console.error('❌ FCM error:', error.message);
    if (error.response) {
      console.error('Response data:', error.response.data);
    }
    res.status(500).json({
      success: false,
      error: error.message,
      details: error.response?.data
    });
  }
});

// Test endpoints for direct testing
app.post('/test-flood-alert', async (req, res) => {
  try {
    const { token } = req.body;
    
    if (!token) {
      return res.status(400).json({
        success: false,
        error: 'FCM token is required'
      });
    }

    // Get fresh OAuth token
    const oauthToken = await getOAuthToken();
    
    // Format for FCM v1 API
    const payload = {
      message: {
        token: token,
        notification: {
          title: '🌊 Flood Alert - Amritsar Central',
          body: 'Severity: HIGH | Water level rising rapidly. Evacuation recommended.'
        },
        data: {
          type: 'flood_alert',
          location: 'Amritsar Central',
          severity: 'HIGH',
          waterLevel: '2.5m',
          status: 'Evacuation Recommended'
        },
        android: {
          notification: {
            icon: 'ic_launcher',
            sound: 'default'
          }
        }
      }
    };

    const response = await axios.post(FCM_URL, payload, {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${oauthToken}`
      }
    });

    res.json({
      success: true,
      message: 'Flood alert sent successfully',
      response: response.data
    });

  } catch (error) {
    console.error('❌ FCM error:', error.message);
    if (error.response) {
      console.error('Response data:', error.response.data);
    }
    res.status(500).json({
      success: false,
      error: error.message,
      details: error.response?.data
    });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 FCM Proxy Server running on http://localhost:${PORT}`);
  console.log(`📱 Ready to send notifications to your device!`);
});

module.exports = app;
