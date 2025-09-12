// lib/models/bug.dart - Updated model for new data structure
import 'package:flutter/material.dart';
import 'package:azlistview/azlistview.dart';

class Bug extends ISuspensionBean {
  final String name;
  final String description;
  final String species;
  final String clinical;
  final String macro;
  final String micro;
  final String histo;
  final String precautions;
  final String susceptibility;
  final List<String> images;
  final List<String> references;

  // For compatibility with existing code and AZListView
  String tag = "";

  Bug({
    required this.name,
    required this.description,
    required this.species,
    required this.clinical,
    required this.macro,
    required this.micro,
    required this.histo,
    required this.precautions,
    required this.susceptibility,
    required this.images,
    required this.references,
  });

  factory Bug.fromMap(Map<String, dynamic> map) {
    return Bug(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      species: map['species'] ?? '',
      clinical: map['clinical'] ?? '',
      macro: map['macro'] ?? '',
      micro: map['micro'] ?? '',
      histo: map['histo'] ?? '',
      precautions: map['precautions'] ?? '',
      susceptibility: map['susceptibility'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      references: List<String>.from(map['references'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'species': species,
      'clinical': clinical,
      'macro': macro,
      'micro': micro,
      'histo': histo,
      'precautions': precautions,
      'susceptibility': susceptibility,
      'images': images,
      'references': references,
    };
  }

  @override
  String getSuspensionTag() => tag;
}
