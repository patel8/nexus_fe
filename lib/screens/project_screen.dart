import 'package:flutter/material.dart';
import 'package:video_generation_ui/api.dart';
import 'package:video_generation_ui/contracts/project.dart';
import 'package:video_generation_ui/screens/script_screen.dart';

class ProjectScreen extends StatelessWidget {
  const ProjectScreen({super.key});
  // Function to create a new project
  Future<Project> createProject() async {
    try {
      ApiService apiService = ApiService();
      final response = await apiService.createProject();
        return Project.fromJson(response['project']);
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome!'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This app is about generating any video within seconds. You can generate or use your script, select a variety of options to choose a voice for your audio, and review the generated images. The magic begins when you generate the video.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Create a new project and navigate to the ScriptPageState with the projectId
                  final projectData = await createProject();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScriptPage(projectId: projectData.id),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Start New Project'),
            ), 
            TextField(
              decoration: const InputDecoration(
                labelText: 'Enter Project ID',
              ),
              onSubmitted: (value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScriptPage(projectId: value),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}