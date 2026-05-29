// João Pedro Panza Mainieri - 25006642;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/decimal_utils.dart';

// ENUMS
enum StartupStatus { ativa, inativa, encerrada }

enum StartupStage { nova, operacao, expansao }

enum StartupVisibility { publica, privada }

class CorporateMember {
  final String name;
  final String role;
  final double equityPercent;
  final String bio;

  CorporateMember({
    required this.name,
    required this.role,
    required this.equityPercent,
    required this.bio,
  });

  factory CorporateMember.fromMap(Map<String, dynamic> map) {
    return CorporateMember(
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      equityPercent: toDouble(map['equity_percent']),
      bio: map['bio'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'role': role,
    'equity_percent': equityPercent,
    'bio': bio,
  };
}

class Startup {
  final String id;
  final String name;
  final String tokenSymbol;
  final IconData icon;
  final StartupStatus status;
  final StartupStage stage;
  final StartupVisibility visibility;
  final List<String> tags;
  final double lastPrice;
  final String shortDescription;
  final String fullDescription;
  final String executiveSummary;
  final List<CorporateMember> corporateStructure;
  final String pitchVideoUrl;
  final String? website;
  final DateTime? foundedAt;
  final double currentRaised;
  final double tokensIssued;
  final int investorsCount;
  final DateTime updatedAt;

  Startup({
    required this.id,
    required this.name,
    required this.tokenSymbol,
    required this.icon,
    required this.status,
    required this.stage,
    required this.visibility,
    required this.tags,
    required this.lastPrice,
    required this.shortDescription,
    required this.fullDescription,
    required this.executiveSummary,
    required this.corporateStructure,
    required this.pitchVideoUrl,
    this.website,
    this.foundedAt,
    required this.currentRaised,
    required this.tokensIssued,
    required this.investorsCount,
    required this.updatedAt,
  });

  factory Startup.fromMap(Map<String, dynamic> map) {
    return Startup(
      id: (map['id'] ?? '').toString(),
      name: map['name'] ?? '',
      tokenSymbol: map['token_symbol'] ?? '',
      icon: _parseIcon(map['icon']),
      status: StartupStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => StartupStatus.inativa,
      ),
      stage: StartupStage.values.firstWhere(
        (e) => e.name == map['stage'],
        orElse: () => StartupStage.nova,
      ),
      visibility: StartupVisibility.values.firstWhere(
        (e) => e.name == map['visibility'],
        orElse: () => StartupVisibility.privada,
      ),
      tags: List<String>.from(map['tags'] ?? []),
      lastPrice: toDouble(map['last_price']),
      shortDescription: map['short_description'] ?? '',
      fullDescription: map['full_description'] ?? '',
      executiveSummary: map['executive_summary'] ?? '',
      corporateStructure: (map['corporate_structure'] as List? ?? [])
          .map((e) => CorporateMember.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      pitchVideoUrl: map['pitch_video_url'] ?? '',
      website: map['website'],
      foundedAt: _parseDate(map['founded_at']),
      currentRaised: toDouble(map['current_raised'] as num? ?? 0),
      tokensIssued: toDouble(map['tokens_issued'] as num? ?? 0),
      investorsCount: map['investors_count'] as int? ?? 0,
      updatedAt: _parseDate(map['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'tokenSymbol': tokenSymbol,
    'icon': icon.codePoint,
    'status': status.name,
    'stage': stage.name,
    'visibility': visibility.name,
    'tags': tags,
    'lastPrice': lastPrice,
    'shortDescription': shortDescription,
    'fullDescription': fullDescription,
    'executiveSummary': executiveSummary,
    'corporateStructure': corporateStructure.map((e) => e.toMap()).toList(),
    'pitchVideoUrl': pitchVideoUrl,
    'website': website,
    'foundedAt': foundedAt != null ? Timestamp.fromDate(foundedAt!) : null,
    'currentRaised': currentRaised,
    'tokensIssued': tokensIssued,
    'investorsCount': investorsCount,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static IconData _parseIcon(dynamic value) {
    if (value is int) return IconData(value, fontFamily: 'MaterialIcons');

    if (value is String) {
      // Remove common prefixes like '0x' or '#' so int.tryParse(..., radix: 16) can read it
      final cleanValue = value.replaceAll('0x', '').replaceAll('#', '');
      final code = int.tryParse(cleanValue, radix: 16);

      if (code != null) return IconData(code, fontFamily: 'MaterialIcons');
    }

    return Icons.help_outline;
  }
}

class SimplifiedStartup {
  final String id;
  final String name;
  final String tokenSymbol;
  final IconData icon;
  final StartupStage stage;
  final List<String> tags;
  final String shortDescription;
  final List<CorporateMember> corporateStructure;
  final double currentRaised;
  final double tokensIssued;
  final int investorsCount;

  SimplifiedStartup({
    required this.id,
    required this.name,
    required this.tokenSymbol,
    required this.icon,
    required this.stage,
    required this.tags,
    required this.shortDescription,
    required this.corporateStructure,
    required this.currentRaised,
    required this.tokensIssued,
    required this.investorsCount,
  });

  factory SimplifiedStartup.fromMap(Map<String, dynamic> map) {
    return SimplifiedStartup(
      id: (map['id'] ?? '').toString(),
      name: map['name'] ?? '',
      tokenSymbol: map['token_symbol'] ?? '',
      icon: Startup._parseIcon(map['icon']),
      stage: StartupStage.values.firstWhere(
        (e) => e.name == map['stage'],
        orElse: () => StartupStage.nova,
      ),
      tags: List<String>.from(map['tags'] ?? []),
      shortDescription: map['short_description'] ?? '',
      corporateStructure: (map['corporate_structure'] as List? ?? [])
          .map((e) => CorporateMember.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      currentRaised: (map['current_raised'] as num? ?? 0).toDouble(),
      tokensIssued: (map['tokens_issued'] as num? ?? 0).toDouble(),
      investorsCount: map['investors_count'] as int? ?? 0,
    );
  }
}

class StartupPriceHistory {
  final double price;
  final DateTime timestamp;

  StartupPriceHistory({required this.price, required this.timestamp});

  factory StartupPriceHistory.fromMap(Map<String, dynamic> map) {
    return StartupPriceHistory(
      price: (map['price'] as num? ?? 0).toDouble(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'price': price,
    'timestamp': Timestamp.fromDate(timestamp),
  };
}
