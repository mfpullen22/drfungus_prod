// lib/models/mycoses.dart - Updated model for new data structure
import 'package:flutter/material.dart';
import 'package:azlistview/azlistview.dart';

class Mycoses extends ISuspensionBean {
  final String name;
  final String overview;
  final String synonyms;
  final String definition;
  final String epidemiology;
  final String clinical;
  final String histo;
  final String labexam;
  final String labiso;
  final String labconfirm;
  final String natural;
  final String treatment;
  final String susceptibility;
  final List<String> images;
  final List<String> references;
  final List<String> trials;

  // For compatibility with existing code and AZListView
  String tag = "";

  Mycoses({
    required this.name,
    required this.overview,
    required this.synonyms,
    required this.definition,
    required this.epidemiology,
    required this.clinical,
    required this.histo,
    required this.labexam,
    required this.labiso,
    required this.labconfirm,
    required this.natural,
    required this.treatment,
    required this.susceptibility,
    required this.images,
    required this.references,
    required this.trials,
  });

  factory Mycoses.fromMap(Map<String, dynamic> map) {
    return Mycoses(
      name: map['name'] ?? '',
      overview: map['overview'] ?? '',
      synonyms: map['synonyms'] ?? '',
      definition: map['definition'] ?? '',
      epidemiology: map['epidemiology'] ?? '',
      clinical: map['clinical'] ?? '',
      histo: map['histo'] ?? '',
      labexam: map['labexam'] ?? '',
      labiso: map['labiso'] ?? '',
      labconfirm: map['labconfirm'] ?? '',
      natural: map['natural'] ?? '',
      treatment: map['treatment'] ?? '',
      susceptibility: map['susceptibility'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      references: List<String>.from(map['references'] ?? []),
      trials: List<String>.from(map['trials'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'overview': overview,
      'synonyms': synonyms,
      'definition': definition,
      'epidemiology': epidemiology,
      'clinical': clinical,
      'histo': histo,
      'labexam': labexam,
      'labiso': labiso,
      'labconfirm': labconfirm,
      'natural': natural,
      'treatment': treatment,
      'susceptibility': susceptibility,
      'images': images,
      'references': references,
      'trials': trials,
    };
  }

  @override
  String getSuspensionTag() => tag;
}

/* // ignore_for_file: non_constant_identifier_names
import 'package:azlistview/azlistview.dart';

class Mycoses with ISuspensionBean {
  Mycoses({
    required this.name,
    required this.name_lower,
    required this.keywords,
    required this.mycology,
    required this.epidemiology,
    required this.clinical,
    required this.pathogenesis,
    required this.diagnosis,
    required this.treatment,
    required this.references,
    required this.trials,
  }) : tag = name[0].toUpperCase();

  final String name;
  String tag;
  final String name_lower;
  final List<dynamic> keywords;
  final String mycology;
  final String epidemiology;
  final String clinical;
  final String pathogenesis;
  final String diagnosis;
  final String treatment;
  final List<dynamic> references;
  final List<dynamic> trials;

  factory Mycoses.fromMap(Map<String, dynamic> map) {
    return Mycoses(
      name: map['name'] ?? '',
      name_lower: map["name_lower"] ?? '',
      keywords: map['keywords'] ?? [""],
      mycology: map['mycology'] ?? {},
      epidemiology: map['epidemiology'] ?? '',
      clinical: map['clinical'] ?? '',
      pathogenesis: map['pathogenesis'] ?? '',
      diagnosis: map['diagnosis'] ?? '',
      treatment: map['treatment'] ?? '',
      references: map['references'] ?? [],
      trials: map['trials'] ?? [],
    );
  }
  @override
  String getSuspensionTag() => tag;
}
 */
