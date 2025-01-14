import 'package:flutter/material.dart';
import 'package:video_generation_ui/api.dart';
import 'package:video_generation_ui/contracts/project.dart';
import 'package:video_generation_ui/screens/generate_audio_screen.dart';


class ScriptPage extends StatefulWidget {
  final String projectId;
  const ScriptPage({super.key, required this.projectId});

  @override
  ScriptPageState createState() => ScriptPageState();
}

class ScriptPageState extends State<ScriptPage> {
  late String projectId;
  final ApiService apiService = ApiService();
  final TextEditingController scriptController = TextEditingController();
  final TextEditingController aiPromptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    projectId = widget.projectId;
    _loadExistingScript(projectId);
  }

  Future<void> _loadExistingScript(String projectId) async {
    try {
      final response = await apiService.getProject(projectId);
      if(response['project'] != null) {
        var project = Project.fromJson(response['project']);
        if(project.scriptPath != null) {
          final scriptResponse = await apiService.getScript(project.id);
          if(scriptResponse['script'] != null) {
            setState(() {
              scriptController.text = scriptResponse['script'];
            });
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _generateScript(String textPrompt) async {
    final response = await apiService.generateScript(textPrompt);
    setState(() {
      scriptController.text = response['script'];
    });
    }

    // Method to upload script to project
  Future<void> _uploadScript(String script) async {
    try {
      final response = await apiService.uploadScript(projectId, script);
      if (response['success']) {
        // Navigate to GenerateAudioScreen after successful upload
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GenerateAudioScreen(projectId: projectId)),
        );
      } else {
        // Handle failure case (you can show an error message here)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to upload script'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      // Handle exception
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Generate Script')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: aiPromptController,
              maxLines: 10,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your script idea, AI will generate script for you',
              ),
            ),
            const SizedBox(height: 16), // Add some space between the TextField and the button
            Center(
              child: TextButton(
                onPressed: () {
                  scriptController.text = 'Generating script...';
                  String textPrompt = aiPromptController.text;
                  _generateScript(textPrompt);
                  // Add the functionality for the 'Generate Script' button here
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue, // Set button background color
                ),
                child: const Text(
                  'Generate Script',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: scriptController,
              maxLines: 10,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Paste your script here to generate video',
              ),
            ),
            const SizedBox(height: 16), 
            Center(
              child: TextButton(
                onPressed: () {
                   String script = scriptController.text;
                  _uploadScript(script); // Upload the script before navigating
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue, // Set button background color
                ),
                child: const Text(
                  'Use this script',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}