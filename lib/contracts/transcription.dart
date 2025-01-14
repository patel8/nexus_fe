class WordTiming {
  String? word;
  double? start;
  double? end;

  WordTiming({this.word, this.start, this.end});

  // From JSON
  factory WordTiming.fromJson(Map<String, dynamic> json) {
    return WordTiming(
      word: json['word'],
      start: json['start']?.toDouble(),
      end: json['end']?.toDouble(),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'start': start,
      'end': end,
    };
  }
}

class Segment {
  double? start;
  double? end;
  String? text;
  String? aiPrompt;
  String? imagePath;
  List<WordTiming>? wordTimings;

  Segment({
    this.start,
    this.end,
    this.text,
    this.aiPrompt,
    this.imagePath,
    this.wordTimings,
  });

  // From JSON
  factory Segment.fromJson(Map<String, dynamic> json) {
    return Segment(
      start: json['start']?.toDouble(),
      end: json['end']?.toDouble(),
      text: json['text'],
      aiPrompt: json['ai_prompt'],
      imagePath: json['image_path'],
      wordTimings: (json['word_timings'] as List?)
          ?.map((item) => WordTiming.fromJson(item))
          .toList(),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
      'text': text,
      'ai_prompt': aiPrompt,
      'image_path': imagePath,
      'word_timings': wordTimings?.map((item) => item.toJson()).toList(),
    };
  }
}

class Transcription {
  List<Segment>? segments;

  Transcription({this.segments});

  // From JSON
  factory Transcription.fromJson(Map<String, dynamic> json) {
    return Transcription(
      segments: (json['segments'] as List?)
          ?.map((item) => Segment.fromJson(item))
          .toList(),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'segments': segments?.map((item) => item.toJson()).toList(),
    };
  }
}