import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/dashboard/services/portfolio_document_parser.dart';

// ─── Holding ──────────────────────────────────────────────────────────────────
// Mirrors the Holding @table in the Firebase schema.
// Firestore path: users/{uid}/holdings/{holdingId}

class Holding {
  final String name;
  final double quantity; // units
  final double costBasis; // amount invested
  final double currentValue;
  final DateTime purchaseDate;
  final String assetType;
  final DateTime createdAt;
  final String portfolioId;
  final String? tickerSymbol;
  final String? notes;

  const Holding({
    required this.name,
    required this.quantity,
    required this.costBasis,
    required this.currentValue,
    required this.purchaseDate,
    required this.assetType,
    required this.createdAt,
    required this.portfolioId,
    this.tickerSymbol,
    this.notes,
  });

  double get returns => currentValue - costBasis;
  double get returnPercentage =>
      costBasis > 0 ? (returns / costBasis) * 100 : 0;
  bool get isProfit => returns >= 0;

  Map<String, dynamic> toMap() => {
    'name': name,
    'quantity': quantity,
    'costBasis': costBasis,
    'currentValue': currentValue,
    'purchaseDate': Timestamp.fromDate(purchaseDate),
    'assetType': assetType,
    'createdAt': FieldValue.serverTimestamp(),
    'portfolioId': portfolioId,
    'tickerSymbol': tickerSymbol ?? '',
    'notes': notes ?? '',
  };

  factory Holding.fromMap(Map<String, dynamic> d) => Holding(
    name: d['name'] ?? '',
    quantity: (d['quantity'] ?? 0).toDouble(),
    costBasis: (d['costBasis'] ?? 0).toDouble(),
    currentValue: (d['currentValue'] ?? 0).toDouble(),
    purchaseDate: d['purchaseDate'] != null
        ? (d['purchaseDate'] as Timestamp).toDate()
        : DateTime.now(),
    assetType: d['assetType'] ?? 'Other',
    createdAt: d['createdAt'] != null
        ? (d['createdAt'] as Timestamp).toDate()
        : DateTime.now(),
    portfolioId: d['portfolioId'] ?? '',
    tickerSymbol: d['tickerSymbol']?.toString().isEmpty == true
        ? null
        : d['tickerSymbol'],
    notes: d['notes']?.toString().isEmpty == true ? null : d['notes'],
  );
}

// ─── HoldingEntry ─────────────────────────────────────────────────────────────
// Holding + its Firestore document ID. Used by UI layers.

class HoldingEntry {
  final String id;
  final Holding holding;

  const HoldingEntry({required this.id, required this.holding});

  String get notes => holding.notes ?? '';

  // Convenience accessor keeps existing UI code working unchanged.
  PortfolioInvestment get investment => PortfolioInvestment(
    name: holding.name,
    type: holding.assetType,
    amountInvested: holding.costBasis,
    currentValue: holding.currentValue,
    dateOfInvestment: holding.purchaseDate,
    units: holding.quantity,
    returns: holding.returns,
  );
}

// Backward-compat alias — existing screens use PortfolioEntry.
typedef PortfolioEntry = HoldingEntry;

// ─── Portfolio ────────────────────────────────────────────────────────────────
// Mirrors the Portfolio @table in the Firebase schema.
// Firestore path: users/{uid}/portfolios/{portfolioId}

class Portfolio {
  final String id;
  final String name;
  final String currency;
  final DateTime createdAt;
  final String? description;

  const Portfolio({
    required this.id,
    required this.name,
    required this.currency,
    required this.createdAt,
    this.description,
  });

  factory Portfolio.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Portfolio(
      id: doc.id,
      name: d['name'] ?? 'My Portfolio',
      currency: d['currency'] ?? 'INR',
      createdAt: d['createdAt'] != null
          ? (d['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      description: d['description'],
    );
  }
}

// ─── PortfolioMetrics ─────────────────────────────────────────────────────────

class PortfolioMetrics {
  final double totalInvestment;
  final double currentValue;
  final double totalReturns;
  final double returnPercentage;

  const PortfolioMetrics({
    required this.totalInvestment,
    required this.currentValue,
    required this.totalReturns,
    required this.returnPercentage,
  });

  bool get isProfit => totalReturns >= 0;
  bool get isEmpty => totalInvestment == 0 && currentValue == 0;
}

// ─── PortfolioService ─────────────────────────────────────────────────────────

class PortfolioService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference _portfoliosRef() =>
      _db.collection('users').doc(_uid).collection('portfolios');

  CollectionReference _holdingsRef() =>
      _db.collection('users').doc(_uid).collection('holdings');

  CollectionReference _uploadsRef() =>
      _db.collection('users').doc(_uid).collection('uploads');

  // ── Portfolio operations ────────────────────────────────────────────────────

  Stream<List<Portfolio>> portfoliosStream() {
    if (_uid == null) return Stream.value([]);
    return _portfoliosRef()
        .orderBy('createdAt')
        .snapshots()
        .map((s) => s.docs.map((d) => Portfolio.fromDoc(d)).toList());
  }

  Future<String> createPortfolio(
    String name, {
    String currency = 'INR',
    String? description,
  }) async {
    if (_uid == null) throw Exception('Not authenticated.');
    final ref = await _portfoliosRef().add({
      'name': name,
      'currency': currency,
      'createdAt': FieldValue.serverTimestamp(),
      'description': description ?? '',
    });
    return ref.id;
  }

  /// Returns the default portfolio ID, creating one if none exists.
  Future<String> getOrCreateDefaultPortfolioId() async {
    if (_uid == null) throw Exception('Not authenticated.');
    final snap = await _portfoliosRef().limit(1).get();
    if (snap.docs.isNotEmpty) return snap.docs.first.id;
    return createPortfolio('My Portfolio');
  }

  // ── Holding operations ──────────────────────────────────────────────────────

  /// Stream ALL holdings for this user — used by dashboard & reports.
  Stream<List<HoldingEntry>> portfolioStream() {
    if (_uid == null) return Stream.value([]);
    return _holdingsRef()
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => HoldingEntry(
                  id: doc.id,
                  holding: Holding.fromMap(doc.data() as Map<String, dynamic>),
                ),
              )
              .toList(),
        );
  }

  /// Stream holdings for a specific portfolio.
  Stream<List<HoldingEntry>> holdingsStream(String portfolioId) {
    if (_uid == null) return Stream.value([]);
    return _holdingsRef()
        .where('portfolioId', isEqualTo: portfolioId)
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => HoldingEntry(
                  id: doc.id,
                  holding: Holding.fromMap(doc.data() as Map<String, dynamic>),
                ),
              )
              .toList(),
        );
  }

  Future<void> addItem(PortfolioInvestment item, {String notes = ''}) async {
    if (_uid == null) {
      throw Exception('Not authenticated. Please log in and try again.');
    }
    final portfolioId = await getOrCreateDefaultPortfolioId();
    await _holdingsRef().add(investmentToMap(item, portfolioId, notes: notes));
  }

  Future<void> updateItem(
    String docId,
    PortfolioInvestment item, {
    String notes = '',
  }) async {
    if (_uid == null) throw Exception('Not authenticated.');
    await _holdingsRef().doc(docId).update({
      'name': item.name,
      'assetType': item.type,
      'costBasis': item.amountInvested,
      'currentValue': item.currentValue,
      'quantity': item.units,
      'purchaseDate': Timestamp.fromDate(item.dateOfInvestment),
      'notes': notes,
    });
  }

  Future<void> deleteItem(String docId) async {
    if (_uid == null) throw Exception('Not authenticated.');
    await _holdingsRef().doc(docId).delete();
  }

  /// Bulk-saves a list of PortfolioInvestment (from file import).
  /// Updates existing holdings if name and type match (case-insensitive).
  Future<int> addBulk(List<PortfolioInvestment> items) async {
    if (_uid == null) {
      throw Exception('Not authenticated. Please log in and try again.');
    }
    if (items.isEmpty) return 0;

    final portfolioId = await getOrCreateDefaultPortfolioId();

    // Fetch existing holdings for this portfolio
    final existingSnap = await _holdingsRef()
        .where('portfolioId', isEqualTo: portfolioId)
        .get();

    final Map<String, String> existingDocs = {
      for (var doc in existingSnap.docs)
        () {
          final d = doc.data() as Map<String, dynamic>;
          final n = (d['name'] ?? '').toString().trim().toLowerCase();
          final t = (d['assetType'] ?? 'Other').toString().trim().toLowerCase();
          return '$n' '_' '$t';
        }(): doc.id,
    };

    WriteBatch batch = _db.batch();
    int count = 0;
    int operationCount = 0;

    for (final item in items) {
      final name = item.name.trim().toLowerCase();
      final type = item.type.trim().toLowerCase();
      final key = '$name' '_' '$type';

      final existingId = existingDocs[key];
      final data = investmentToMap(item, portfolioId);

      if (existingId != null) {
        // Update existing - preserve createdAt, manual notes, and symbols
        data.remove('createdAt');
        data.remove('notes');
        data.remove('tickerSymbol');
        batch.update(_holdingsRef().doc(existingId), data);
      } else {
        // Create new
        batch.set(_holdingsRef().doc(), data);
      }

      count++;
      operationCount++;

      // Firestore write batch limit is 500 operations
      if (operationCount >= 500) {
        await batch.commit();
        batch = _db.batch();
        operationCount = 0;
      }
    }

    if (operationCount > 0) {
      await batch.commit();
    }

    return count;
  }

  /// Converts a PortfolioInvestment to a Map.
  /// Set [forFirestore] to false for JSON-friendly output (e.g., for Gemini API).
  static Map<String, dynamic> investmentToMap(
    PortfolioInvestment item,
    String portfolioId, {
    String notes = '',
    bool forFirestore = true,
  }) => {
    'name': item.name,
    'quantity': item.units,
    'costBasis': item.amountInvested,
    'currentValue': item.currentValue,
    'purchaseDate': forFirestore
        ? Timestamp.fromDate(item.dateOfInvestment)
        : item.dateOfInvestment.toIso8601String(),
    'assetType': item.type,
    if (forFirestore) 'createdAt': FieldValue.serverTimestamp(),
    'portfolioId': portfolioId,
    'tickerSymbol': '',
    'notes': notes,
  };

  // ── Upload tracking ─────────────────────────────────────────────────────────

  Future<void> recordUpload({
    required String filename,
    required String fileType,
    required String status,
    String? processingLog,
  }) async {
    if (_uid == null) return;
    await _uploadsRef().add({
      'filename': filename,
      'fileType': fileType,
      'uploadDate': FieldValue.serverTimestamp(),
      'status': status,
      'processingLog': processingLog ?? '',
    });
  }

  // ── Metrics ─────────────────────────────────────────────────────────────────

  static PortfolioMetrics calculateMetrics(List<HoldingEntry> entries) {
    if (entries.isEmpty) {
      return const PortfolioMetrics(
        totalInvestment: 0,
        currentValue: 0,
        totalReturns: 0,
        returnPercentage: 0,
      );
    }
    final totalInvestment = entries.fold<double>(
      0,
      (s, e) => s + e.holding.costBasis,
    );
    final currentValue = entries.fold<double>(
      0,
      (s, e) => s + e.holding.currentValue,
    );
    final totalReturns = currentValue - totalInvestment;
    final returnPercentage = totalInvestment > 0
        ? (totalReturns / totalInvestment) * 100
        : 0.0;
    return PortfolioMetrics(
      totalInvestment: totalInvestment,
      currentValue: currentValue,
      totalReturns: totalReturns,
      returnPercentage: returnPercentage,
    );
  }
}
