/// Quality assessment result from the pre-shutter quality gate.
///
/// Refuses blurred or poorly lit frames *before* the shutter fires
/// and provides spoken guidance in the artisan's language.
library;

enum QualityIssue {
  none,
  blur,
  tooDark,
  backlight,
}

class QualityAssessment {
  const QualityAssessment({
    required this.isAcceptable,
    required this.issue,
    required this.blurScore,
    required this.brightnessScore,
    required this.backlightScore,
    this.guidanceMessage,
  });

  /// High quality frame ready for shutter capture.
  factory QualityAssessment.pass({
    double blurScore = 100.0,
    double brightnessScore = 128.0,
    double backlightScore = 1.0,
  }) {
    return QualityAssessment(
      isAcceptable: true,
      issue: QualityIssue.none,
      blurScore: blurScore,
      brightnessScore: brightnessScore,
      backlightScore: backlightScore,
    );
  }

  /// Quality failure with a specific issue and guidance reason.
  factory QualityAssessment.fail({
    required QualityIssue issue,
    required double blurScore,
    required double brightnessScore,
    required double backlightScore,
    String? guidanceMessage,
  }) {
    return QualityAssessment(
      isAcceptable: false,
      issue: issue,
      blurScore: blurScore,
      brightnessScore: brightnessScore,
      backlightScore: backlightScore,
      guidanceMessage: guidanceMessage,
    );
  }

  final bool isAcceptable;
  final QualityIssue issue;
  final double blurScore;
  final double brightnessScore;
  final double backlightScore;
  final String? guidanceMessage;

  /// Returns localized translation key matching ARB schema.
  String? get arbKey => switch (issue) {
        QualityIssue.blur => 'qualityBlur',
        QualityIssue.tooDark => 'qualityDark',
        QualityIssue.backlight => 'qualityBacklight',
        QualityIssue.none => null,
      };

  @override
  String toString() =>
      'QualityAssessment(acceptable: $isAcceptable, issue: $issue, blur: ${blurScore.toStringAsFixed(1)}, brightness: ${brightnessScore.toStringAsFixed(1)})';
}
