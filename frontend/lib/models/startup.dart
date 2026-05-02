import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ENUMS

//Useri factory para facilitar transformar o retorno do firestore

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
      equityPercent: (map['equity_percent'] as num? ?? 0).toDouble(),
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

class StartupDetails {
  final String fullDescription;
  final String executiveSummary;
  final List<CorporateMember> corporateStructure;
  final String pitchVideoUrl;
  final String? website;
  final DateTime? foundedAt;

  StartupDetails({
    required this.fullDescription,
    required this.executiveSummary,
    required this.corporateStructure,
    required this.pitchVideoUrl,
    this.website,
    this.foundedAt,
  });

  factory StartupDetails.fromMap(Map<String, dynamic> map) {
    DateTime? parsedDate;
    if (map['founded_at'] != null) {
      if (map['founded_at'] is Timestamp) {
        parsedDate = (map['founded_at'] as Timestamp).toDate();
      } else if (map['founded_at'] is String) {
        parsedDate = DateTime.tryParse(map['founded_at']);
      }
    }

    return StartupDetails(
      fullDescription: map['full_description'] ?? '',
      executiveSummary: map['executive_summary'] ?? '',
      corporateStructure: (map['corporate_structure'] as List? ?? [])
          .map((e) => CorporateMember.fromMap(e as Map<String, dynamic>))
          .toList(),
      pitchVideoUrl: map['pitch_video_url'] ?? '',
      website: map['website'],
      foundedAt: parsedDate,
    );
  }

  Map<String, dynamic> toMap() => {
    'full_description': fullDescription,
    'executive_summary': executiveSummary,
    'corporate_structure': corporateStructure.map((e) => e.toMap()).toList(),
    'pitch_video_url': pitchVideoUrl,
    'website': website,
    'founded_at': foundedAt != null ? Timestamp.fromDate(foundedAt!) : null,
  };
}

class StartupMetrics {
  final double currentRaised;
  final double tokensEmitidos;
  final int investorsCount;

  StartupMetrics({
    required this.currentRaised,
    required this.tokensEmitidos,
    required this.investorsCount,
  });

  factory StartupMetrics.fromMap(Map<String, dynamic> map) {
    return StartupMetrics(
      currentRaised: (map['current_raised'] as num? ?? 0).toDouble(),
      tokensEmitidos: (map['tokens_emitidos'] as num? ?? 0).toDouble(),
      investorsCount: map['investors_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'current_raised': currentRaised,
    'tokens_emitidos': tokensEmitidos,
    'investors_count': investorsCount,
  };
}

class Startup {
  final String name;
  final String tokenSymbol;
  final IconData icon; // Agora como IconData
  final StartupStatus status;
  final StartupStage estagio;
  final StartupVisibility visibility;
  final String category;
  final double lastPrice;
  final String shortDescription;
  final StartupDetails details;
  final StartupMetrics metrics;
  final DateTime updatedAt;
  final List<String> tags;

  Startup({
    required this.name,
    required this.tokenSymbol,
    required this.icon,
    required this.status,
    required this.estagio,
    required this.visibility,
    required this.category,
    required this.lastPrice,
    required this.shortDescription,
    required this.details,
    required this.metrics,
    required this.updatedAt,
    required this.tags,
  });

  factory Startup.fromMap(Map<String, dynamic> map) {
    return Startup(
      name: map['name'] ?? '',
      tokenSymbol: map['token_symbol'] ?? '',
      icon: IconData(
        map['icon'] as int? ?? Icons.help_outline.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      status: StartupStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => StartupStatus.inativa,
      ),
      estagio: StartupStage.values.firstWhere(
        (e) => e.name == map['estagio'],
        orElse: () => StartupStage.nova,
      ),
      visibility: StartupVisibility.values.firstWhere(
        (e) =>
            e.name ==
            map['visibilitie'], // Mapeando de 'visibilitie' (TS) para 'visibility'
        orElse: () => StartupVisibility.privada,
      ),
      category: map['category'] ?? '',
      lastPrice: (map['last_price'] as num? ?? 0).toDouble(),
      shortDescription: map['short_description'] ?? '',
      details: StartupDetails.fromMap(
        map['details'] as Map<String, dynamic>? ?? {},
      ),
      metrics: StartupMetrics.fromMap(
        map['metrics'] as Map<String, dynamic>? ?? {},
      ),
      updatedAt: map['updated_at'] is Timestamp
          ? (map['updated_at'] as Timestamp).toDate()
          : DateTime.tryParse(map['updated_at']?.toString() ?? '') ??
                DateTime.now(),
      tags: map['tags'] as List<String>,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'token_symbol': tokenSymbol,
    'icon': icon.codePoint,
    'status': status.name,
    'estagio': estagio.name,
    'visibilitie': visibility.name, // Mantendo 'visibilitie' para o banco
    'category': category,
    'last_price': lastPrice,
    'short_description': shortDescription,
    'details': details.toMap(),
    'metrics': metrics.toMap(),
    'updated_at': Timestamp.fromDate(updatedAt),
  };
}
