// firebase_portfolio_service.dart
//
// Upload pipeline for Firebase:
//   uploadFile()       — Firebase Storage bucket "portfolios"
//   insertToDatabase() — Firestore collection "portfolios" (metadata)
//   uploadPortfolio()  — convenience wrapper that calls both in order
//   triggerAiAnalysis()— stub for AI backend
//
// Every error is captured and re-thrown as a PortfolioUploadException.


import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebasePortfolioService {
  FirebasePortfolioService._();
  static final FirebasePortfolioService instance = FirebasePortfolioService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _storageFolder = 'portfolios';
  static const String _collection = 'portfolios_metadata';

  // ─────────────────────────────────────────────────────────────────────────
  // 1. uploadFile
  // ─────────────────────────────────────────────────────────────────────────

  Future<String> uploadFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final uid = _currentUid();
    final path = _buildStoragePath(uid, fileName);

    debugPrint('════ [Firebase: uploadFile] ══════════════');
    debugPrint('[uploadFile] path     : $path');
    debugPrint('[uploadFile] bytes    : ${bytes.length}');
    debugPrint('[uploadFile] mimeType : $mimeType');

    try {
      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(contentType: mimeType);
      
      final uploadTask = ref.putData(bytes, metadata);
      final snapshot = await uploadTask;
      
      final url = await snapshot.ref.getDownloadURL();
      debugPrint('[uploadFile] ✅ Upload succeeded: $url');
      return url;
    } on FirebaseException catch (e, stack) {
      debugPrint('[uploadFile] ❌ FirebaseException: $e');
      debugPrint('[uploadFile] stack :\n$stack');
      throw PortfolioUploadException('[Upload error] ${e.message ?? e.toString()}');
    } catch (e, stack) {
      debugPrint('[uploadFile] ❌ Unexpected: $e');
      debugPrint('[uploadFile] stack :\n$stack');
      throw PortfolioUploadException('[Upload error] $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2. insertToDatabase
  // ─────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> insertToDatabase({
    required String fileName,
    required String fileUrl,
  }) async {
    final uid = _currentUid();

    debugPrint('════ [Firebase: insertToDatabase] ════════');
    debugPrint('[insertToDatabase] user_id   : $uid');
    debugPrint('[insertToDatabase] file_name : $fileName');

    try {
      final docRef = await _db.collection('users').doc(uid).collection(_collection).add({
        'user_id': uid,
        'file_name': fileName,
        'file_url': fileUrl,
        'created_at': FieldValue.serverTimestamp(),
      });

      final doc = await docRef.get();
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      
      debugPrint('[insertToDatabase] ✅ Insert succeeded: ${doc.id}');
      return data;
    } catch (e, stack) {
      debugPrint('[insertToDatabase] ❌ Error: $e');
      debugPrint('[insertToDatabase] stack :\n$stack');
      throw PortfolioUploadException('[DB error] $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3. uploadPortfolio  — full pipeline
  // ─────────────────────────────────────────────────────────────────────────

  Future<FirebaseUploadResult> uploadPortfolio({
    required String fileName,
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    final mimeType = _mimeType(fileExtension);

    debugPrint('════ [Firebase: uploadPortfolio] ═════════');
    debugPrint('[uploadPortfolio] fileName      : $fileName');
    debugPrint('[uploadPortfolio] fileExtension : $fileExtension');

    // 1. Upload to Storage
    final fileUrl = await uploadFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: mimeType,
    );

    // 2. Insert metadata to Firestore
    final record = await insertToDatabase(
      fileName: fileName,
      fileUrl: fileUrl,
    );

    final id = record['id'] as String? ?? '';
    return FirebaseUploadResult(id: id, fileUrl: fileUrl, fileName: fileName);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4. triggerAiAnalysis
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> triggerAiAnalysis(String fileUrl) async {
    debugPrint('[triggerAiAnalysis] stub called — fileUrl: $fileUrl');
    await Future.delayed(const Duration(seconds: 2));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  String _currentUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw const PortfolioUploadException(
        '[Auth error] No authenticated user. Please log in and try again.',
      );
    }
    return uid;
  }

  static String _sanitizeFileName(String name) =>
      name.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w.\-]'), '');

  static String _buildStoragePath(String uid, String originalName) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final sanitized = _sanitizeFileName(originalName);
    return '$_storageFolder/$uid/${ts}_$sanitized';
  }

  static String _mimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'csv':
        return 'text/csv';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'xls':
        return 'application/vnd.ms-excel';
      default:
        return 'application/octet-stream';
    }
  }
}

class FirebaseUploadResult {
  final String id;
  final String fileUrl;
  final String fileName;
  const FirebaseUploadResult({
    required this.id,
    required this.fileUrl,
    required this.fileName,
  });
}

class PortfolioUploadException implements Exception {
  final String message;
  const PortfolioUploadException(this.message);

  @override
  String toString() => message;
}
