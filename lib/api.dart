import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://127.0.0.1:8000'; // Replace with your FastAPI server URL

  // Method to create a project
  Future<Map<String, dynamic>> createProject() async {
    final url = Uri.parse('$baseUrl/project/createProject');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create project');
    }
  }

  // Method to get available voices
  Future<Map<String, dynamic>> getVoices() async {
    final url = Uri.parse('$baseUrl/get_voices');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch voices');
    }
  }

  // Method to get project details
  Future<Map<String, dynamic>> getProject(String projectId) async {
    final url = Uri.parse('$baseUrl/project/$projectId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch project');
    }
  }

    // Method to get project details
  Future<Map<String, dynamic>> getScript(String projectId) async {
    final url = Uri.parse('$baseUrl/script/$projectId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    else if(response.statusCode == 404) {
      return {"script": null};  
    } else {
      throw Exception('Failed to fetch project');
    }
  }


  // Method to generate script
  Future<Map<String, dynamic>> generateScript(String textPrompt) async {
    final url = Uri.parse('$baseUrl/script/generate_script');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": textPrompt}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate script');
    }
  }

  // Method to upload script to project
  Future<Map<String, dynamic>> uploadScript(
      String projectId, String script) async {
    final url = Uri.parse('$baseUrl/project/$projectId/script');
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"script": script}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to upload script');
    }
  }

  // Method to generate audio for the project
  Future<Map<String, dynamic>> generateAudio(String projectId) async {
    final url = Uri.parse('$baseUrl/project/$projectId/generate_audio');
    final response = await http.put(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate audio');
    }
  }

  // Method to transcribe audio for the project
  Future<Map<String, dynamic>> transcribeAudio(String projectId) async {
    final url = Uri.parse('$baseUrl/project/$projectId/transcribe_audio');
    final response = await http.put(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to transcribe audio');
    }
  }

  // New Method to get transcription for the project
  Future<Map<String, dynamic>> getTranscription(String projectId) async {
    final url = Uri.parse('$baseUrl/project/$projectId/get_transcription');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return {"transcription": null};
    } else {
      throw Exception('Failed to get transcription');
    }
  }

  // Method to generate video for the project
  Future<Map<String, dynamic>> generateVideo(String projectId) async {
    final url = Uri.parse('$baseUrl/project/$projectId/generate_video');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate video');
    }
  }

  // New function to replace the image
  Future<Map<String, dynamic>> replaceImage(
      String projectId, int transcriptionIndex) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/project/$projectId/replace_image?transcription_index=$transcriptionIndex'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate video');
    }
  }

  Future<Map<String, dynamic>> getSasUrlForAudio(String projectId) async {
    final url = Uri.parse('$baseUrl/audio/$projectId/get_sas_url');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get SAS URL for audio');
    }
  }

    Future<Map<String, dynamic>> getSasUrlForVideo(String projectId) async {
    final url = Uri.parse('$baseUrl/video/$projectId/get_sas_url');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get SAS URL for audio');
    }
  }
}
