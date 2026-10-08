import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CreditService {
  static const String _creditsCollection = 'user_credits';
  static const String _transactionsCollection = 'credit_transactions';
  
  // Credit amounts for different actions
  static const int volunteerRequestCredit = 10; // When user selects option 3 (volunteer)
  static const int emergencyReportCredit = 5;   // When user selects option 1 (emergency)
  static const int foodShelterCredit = 3;       // When user selects option 2 (food/shelter)
  
  // In-memory cache for fast UI access
  static final Map<String, int> _creditCache = {};

  // Get current user's credit balance with fast cache
  static Future<int> getUserCredits(String userId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _creditCache.containsKey(userId)) {
      return _creditCache[userId]!;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection(_creditsCollection)
          .doc(userId)
          .get();
      
      if (doc.exists) {
        final balance = doc.data()?['balance'] ?? 0;
        _creditCache[userId] = balance;
        return balance;
      } else {
        // Create new credit account for user
        await FirebaseFirestore.instance
            .collection(_creditsCollection)
            .doc(userId)
            .set({'balance': 0, 'createdAt': FieldValue.serverTimestamp()});
        _creditCache[userId] = 0;
        return 0;
      }
    } catch (e) {
      debugPrint('Error getting user credits: $e');
      return _creditCache[userId] ?? 0;
    }
  }
  
  // Award credits for IVR choice
  static Future<bool> awardCreditsForIVRChoice(String userId, int choice) async {
    try {
      int creditAmount = 0;
      String action = '';
      
      switch (choice) {
        case 1:
          creditAmount = emergencyReportCredit;
          action = 'Emergency Report';
          break;
        case 2:
          creditAmount = foodShelterCredit;
          action = 'Food/Shelter Request';
          break;
        case 3:
          creditAmount = volunteerRequestCredit;
          action = 'Volunteer Request';
          break;
        default:
          return false;
      }
      
      if (creditAmount > 0) {
        // Update user's credit balance safely
        await FirebaseFirestore.instance
            .collection(_creditsCollection)
            .doc(userId)
            .set({
          'balance': FieldValue.increment(creditAmount),
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        // Record transaction
        await FirebaseFirestore.instance
            .collection(_transactionsCollection)
            .add({
          'userId': userId,
          'amount': creditAmount,
          'action': action,
          'choice': choice,
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'earned',
        });
        
        if (_creditCache.containsKey(userId)) {
          _creditCache[userId] = (_creditCache[userId] ?? 0) + creditAmount;
        }
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error awarding credits: $e');
      return false;
    }
  }
  
  // Get user's credit transaction history
  static Stream<QuerySnapshot> getUserCreditHistory(String userId) {
    return FirebaseFirestore.instance
        .collection(_transactionsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  
  // Get leaderboard (top users by credits)
  static Stream<QuerySnapshot> getLeaderboard({int limit = 10}) {
    return FirebaseFirestore.instance
        .collection(_creditsCollection)
        .orderBy('balance', descending: true)
        .limit(limit)
        .snapshots();
  }
  
  // Redeem credits (for future features like rewards)
  static Future<bool> redeemCredits(String userId, int amount, String reason) async {
    try {
      final currentCredits = await getUserCredits(userId);
      
      if (currentCredits < amount) {
        return false; // Insufficient credits
      }
      
      // Update balance
      await FirebaseFirestore.instance
            .collection(_creditsCollection)
            .doc(userId)
            .update({
        'balance': FieldValue.increment(-amount),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      if (_creditCache.containsKey(userId)) {
        _creditCache[userId] = (_creditCache[userId] ?? 0) - amount;
      }
      
      // Record transaction
      await FirebaseFirestore.instance
            .collection(_transactionsCollection)
            .add({
        'userId': userId,
        'amount': -amount,
        'action': reason,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'redeemed',
      });
      
      return true;
    } catch (e) {
      debugPrint('Error redeeming credits: $e');
      return false;
    }
  }
  
  // Get credit statistics
  static Future<Map<String, dynamic>> getCreditStats() async {
    try {
      final creditsSnapshot = await FirebaseFirestore.instance
          .collection(_creditsCollection)
          .get();
      
      final transactionsSnapshot = await FirebaseFirestore.instance
          .collection(_transactionsCollection)
          .get();
      
      int totalUsers = creditsSnapshot.docs.length;
      int totalCredits = 0;
      int totalTransactions = transactionsSnapshot.docs.length;
      
      for (var doc in creditsSnapshot.docs) {
        totalCredits += (doc.data()['balance'] as num? ?? 0).toInt();
      }
      
      return {
        'totalUsers': totalUsers,
        'totalCredits': totalCredits,
        'totalTransactions': totalTransactions,
        'averageCredits': totalUsers > 0 ? (totalCredits / totalUsers).round() : 0,
      };
    } catch (e) {
      debugPrint('Error getting credit stats: $e');
      return {
        'totalUsers': 0,
        'totalCredits': 0,
        'totalTransactions': 0,
        'averageCredits': 0,
      };
    }
  }
}
