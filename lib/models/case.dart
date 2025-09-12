// lib/models/case.dart
class Case {
  final String title;
  final String author;
  final String institution;
  final String month;
  final String year;
  final String email;
  final String history;
  final String exam;
  final String labs;
  final List<Map<String, String>> images;
  final List<Map<String, String>> questions;
  final String discussion;
  final List<String> references;

  Case({
    required this.title,
    required this.author,
    required this.institution,
    required this.month,
    required this.year,
    required this.email,
    required this.history,
    required this.exam,
    required this.labs,
    required this.images,
    required this.questions,
    required this.discussion,
    required this.references,
  });

  factory Case.fromMap(Map<String, dynamic> map) {
    return Case(
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      institution: map['institution'] ?? '',
      month: map['month'] ?? '',
      year: map['year']?.toString() ?? '',
      email: map['email'] ?? '',
      history: map['history'] ?? '',
      exam: map['exam'] ?? '',
      labs: map['labs'] ?? '',
      images: List<Map<String, String>>.from(
        (map['images'] ?? []).map((item) => Map<String, String>.from(item)),
      ),
      questions: List<Map<String, String>>.from(
        (map['questions'] ?? []).map((item) => Map<String, String>.from(item)),
      ),
      discussion: map['discussion'] ?? '',
      references: List<String>.from(map['references'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'institution': institution,
      'month': month,
      'year': year,
      'email': email,
      'history': history,
      'exam': exam,
      'labs': labs,
      'images': images,
      'questions': questions,
      'discussion': discussion,
      'references': references,
    };
  }

  // Helper method for chronological sorting
  DateTime get dateTime {
    // Convert month name to number for sorting
    const monthMap = {
      'january': 1,
      'february': 2,
      'march': 3,
      'april': 4,
      'may': 5,
      'june': 6,
      'july': 7,
      'august': 8,
      'september': 9,
      'october': 10,
      'november': 11,
      'december': 12,
    };

    final monthNumber = monthMap[month.toLowerCase()] ?? 1;
    final yearInt = int.tryParse(year) ?? DateTime.now().year;
    return DateTime(yearInt, monthNumber);
  }

  // Helper method for display
  String get monthYearDisplay => '$month $year';
}
