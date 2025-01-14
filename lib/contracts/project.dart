
class Project {
  final String id;
  final String? scriptPath;
  final String? audioPath;
  final String? transcriptionPath;
  final String? backgroundMusicPath;
  final String? generatedVideoPath;
  final String? fontPath;

  Project({
    required this.id,
    this.scriptPath,
    this.audioPath,
    this.transcriptionPath,
    this.backgroundMusicPath,
    this.generatedVideoPath,
    this.fontPath,
  });

  // Method to create a Project object from a JSON map
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['_id'] as String,
      scriptPath: json['script_path'] as String?,
      audioPath: json['audio_path'] as String?,
      transcriptionPath: json['transcription_path'] as String?,
      backgroundMusicPath: json['background_music_path'] as String?,
      generatedVideoPath: json['generated_video_path'] as String?,
      fontPath: json['font_path'] as String?,
    );
  }

  // Method to convert a Project object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'script_path': scriptPath,
      'audio_path': audioPath,
      'transcription_path': transcriptionPath,
      'background_music_path': backgroundMusicPath,
      'generated_video_path': generatedVideoPath,
      'font_path': fontPath,
    };
  }
}
