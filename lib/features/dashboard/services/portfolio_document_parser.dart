// portfolio_document_parser.dart
// Parses uploaded investment documents (CSV, Excel, simulated) into structured data.

class PortfolioInvestment {
  final String name;
  final String type;
  final double amountInvested;
  final double currentValue;
  final DateTime dateOfInvestment;
  final double units;
  final double returns;

  PortfolioInvestment({
    required this.name,
    required this.type,
    required this.amountInvested,
    required this.currentValue,
    required this.dateOfInvestment,
    required this.units,
    required this.returns,
  });

  double get returnPercentage =>
      amountInvested > 0 ? (returns / amountInvested) * 100 : 0;

  bool get isProfit => returns >= 0;

  factory PortfolioInvestment.fromCsvRow(List<String> row) {
    return PortfolioInvestment(
      name: row.isNotEmpty ? row[0].trim() : 'Unknown',
      type: row.length > 1 ? row[1].trim() : 'Other',
      amountInvested: row.length > 2 ? _parseAmount(row[2]) : 0,
      currentValue: row.length > 3 ? _parseAmount(row[3]) : 0,
      dateOfInvestment: row.length > 4 ? _parseDate(row[4]) : DateTime.now(),
      units: row.length > 5 ? _parseAmount(row[5]) : 0,
      returns: row.length > 6
          ? _parseAmount(row[6])
          : (row.length > 3 ? _parseAmount(row[3]) - _parseAmount(row[2]) : 0),
    );
  }

  static double _parseAmount(String value) {
    final cleaned = value.trim().replaceAll(RegExp(r'[₹,\s]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  static DateTime _parseDate(String value) {
    final parts = value.trim().split(RegExp(r'[/\-]'));
    if (parts.length == 3) {
      try {
        // Try dd/mm/yyyy
        if (parts[0].length <= 2) {
          return DateTime(
              int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
        // Try yyyy-mm-dd
        return DateTime(
            int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      } catch (_) {}
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'amountInvested': amountInvested,
        'currentValue': currentValue,
        'dateOfInvestment': dateOfInvestment.toIso8601String(),
        'units': units,
        'returns': returns,
        'returnPercentage': returnPercentage,
      };
}

class PortfolioDocumentParser {
  /// Parses CSV text content line by line.
  static List<PortfolioInvestment> parseCsv(String content) {
    final List<PortfolioInvestment> investments = [];
    final lines = content.split('\n');

    // Skip header row
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final row = _parseCsvLine(line);
      if (row.length >= 4) {
        try {
          investments.add(PortfolioInvestment.fromCsvRow(row));
        } catch (_) {
          // Skip malformed rows
        }
      }
    }
    return investments;
  }

  /// Splits a CSV line respecting quoted fields.
  static List<String> _parseCsvLine(String line) {
    final List<String> result = [];
    final StringBuffer current = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      if (line[i] == '"') {
        inQuotes = !inQuotes;
      } else if (line[i] == ',' && !inQuotes) {
        result.add(current.toString());
        current.clear();
      } else {
        current.write(line[i]);
      }
    }
    result.add(current.toString());
    return result;
  }

  /// Returns the portfolio parsed from finvestea_portfolio_sample.xlsx.
  /// Columns: Investment Name | Investment Type | Amount Invested (INR) |
  ///          Current Value (INR) | Units | Date of Investment | Returns (INR)
  ///
  /// Extracted data:
  /// | Investment Name       | Type        | Invested | Current  | Units | Date       | Returns |
  /// | Reliance Industries   | Stock       | 100000   | 125000   | 50    | 2023-02-10 | 25000   |
  /// | TCS                   | Stock       | 80000    | 96000    | 40    | 2023-06-15 | 16000   |
  /// | HDFC Top 100 Fund     | Mutual Fund | 120000   | 138000   | 600   | 2022-11-05 | 18000   |
  /// | Gold ETF              | ETF         | 50000    | 57500    | 25    | 2024-01-20 | 7500    |
  /// | SBI Bluechip Fund     | Mutual Fund | 90000    | 99000    | 450   | 2023-08-12 | 9000    |
  ///
  /// Portfolio Summary:
  ///   Total Invested  : ₹4,40,000
  ///   Current Value   : ₹5,15,500
  ///   Total Returns   : ₹75,500
  ///   Return %        : 17.16%
  static List<PortfolioInvestment> getDemoPortfolio() {
    return [
      PortfolioInvestment(
        name: 'Reliance Industries',
        type: 'Stock',
        amountInvested: 100000,
        currentValue: 125000,
        dateOfInvestment: DateTime(2023, 2, 10),
        units: 50.0,
        returns: 25000,
      ),
      PortfolioInvestment(
        name: 'TCS',
        type: 'Stock',
        amountInvested: 80000,
        currentValue: 96000,
        dateOfInvestment: DateTime(2023, 6, 15),
        units: 40.0,
        returns: 16000,
      ),
      PortfolioInvestment(
        name: 'HDFC Top 100 Fund',
        type: 'Mutual Fund',
        amountInvested: 120000,
        currentValue: 138000,
        dateOfInvestment: DateTime(2022, 11, 5),
        units: 600.0,
        returns: 18000,
      ),
      PortfolioInvestment(
        name: 'Gold ETF',
        type: 'ETF',
        amountInvested: 50000,
        currentValue: 57500,
        dateOfInvestment: DateTime(2024, 1, 20),
        units: 25.0,
        returns: 7500,
      ),
      PortfolioInvestment(
        name: 'SBI Bluechip Fund',
        type: 'Mutual Fund',
        amountInvested: 90000,
        currentValue: 99000,
        dateOfInvestment: DateTime(2023, 8, 12),
        units: 450.0,
        returns: 9000,
      ),
    ];
  }

  /// Parses raw Excel rows (already decoded from bytes via the `excel` package).
  /// Each row is a List of cell values as dynamic.
  /// Expected columns (0-indexed):
  ///   0: Investment Name, 1: Investment Type, 2: Amount Invested,
  ///   3: Current Value,   4: Units,           5: Date of Investment,
  ///   6: Returns
  static List<PortfolioInvestment> parseExcelRows(
      List<List<dynamic>> rows) {
    final List<PortfolioInvestment> investments = [];
    // Skip header row (index 0)
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || row[0] == null) continue;
      try {
        investments.add(PortfolioInvestment(
          name: row[0]?.toString().trim() ?? 'Unknown',
          type: row.length > 1 ? (row[1]?.toString().trim() ?? 'Other') : 'Other',
          amountInvested: row.length > 2 ? _parseDynamic(row[2]) : 0,
          currentValue: row.length > 3 ? _parseDynamic(row[3]) : 0,
          units: row.length > 4 ? _parseDynamic(row[4]) : 0,
          dateOfInvestment: row.length > 5 ? _parseDynamicDate(row[5]) : DateTime.now(),
          returns: row.length > 6
              ? _parseDynamic(row[6])
              : (row.length > 3
                  ? _parseDynamic(row[3]) - _parseDynamic(row[2])
                  : 0),
        ));
      } catch (_) {
        // Skip malformed rows
      }
    }
    return investments;
  }

  static double _parseDynamic(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    final cleaned = value.toString().trim().replaceAll(RegExp(r'[₹,\s]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  static DateTime _parseDynamicDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    return PortfolioInvestment._parseDate(value.toString());
  }

  /// Validates that a file name has a supported extension.
  static bool isSupportedFormat(String fileName) {
    final ext = fileName.toLowerCase();
    return ext.endsWith('.csv') ||
        ext.endsWith('.xlsx') ||
        ext.endsWith('.xls') ||
        ext.endsWith('.pdf');
  }

  /// Returns a user-friendly validation message.
  static String? validateFile(String fileName, int fileSizeBytes) {
    if (!isSupportedFormat(fileName)) {
      return 'Unsupported format. Please upload CSV, Excel (.xlsx/.xls) or PDF.';
    }
    if (fileSizeBytes > 10 * 1024 * 1024) {
      return 'File size exceeds 10MB limit. Please upload a smaller file.';
    }
    return null;
  }
}
