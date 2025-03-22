class Exercise {
  final int eid;
  final String exercise;
  final String? shortYoutubeDemonstration;
  final String? indepthYoutubeExplanation;
  final String difficultyLevel;
  final String targetMuscleGroup;
  final String primeMoverMuscle;
  final String? secondaryMuscle;
  final String? tertiaryMuscle;
  final String primaryEquipment;
  final String secondaryEquipment;
  final String bodyRegion;
  final String forceType;
  final String mechanics;
  final String primaryExerciseClassification;
  final String setsXReps;

  Exercise({
    required this.eid,
    required this.exercise,
    this.shortYoutubeDemonstration,
    this.indepthYoutubeExplanation,
    required this.difficultyLevel,
    required this.targetMuscleGroup,
    required this.primeMoverMuscle,
    this.secondaryMuscle,
    this.tertiaryMuscle,
    required this.primaryEquipment,
    required this.secondaryEquipment,
    required this.bodyRegion,
    required this.forceType,
    required this.mechanics,
    required this.primaryExerciseClassification,
    required this.setsXReps,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      eid: json['eid'],
      exercise: json['exercise'],
      shortYoutubeDemonstration: json['short_youtube_demonstration'],
      indepthYoutubeExplanation: json['indepth_youtube_explanation'],
      difficultyLevel: json['difficulty_level'],
      targetMuscleGroup: json['target_muscle_group'],
      primeMoverMuscle: json['prime_mover_muscle'],
      secondaryMuscle: json['secondary_muscle'],
      tertiaryMuscle: json['tertiary_muscle'],
      primaryEquipment: json['primary_equipment'],
      secondaryEquipment: json['secondary_equipment'],
      bodyRegion: json['body_region'],
      forceType: json['force_type'],
      mechanics: json['mechanics'],
      primaryExerciseClassification: json['primary_exercise_classification'],
      setsXReps: json['setsxreps'],
    );
  }
}
