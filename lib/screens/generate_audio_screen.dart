import 'package:flutter/material.dart';
import 'package:video_generation_ui/api.dart';
import 'package:video_generation_ui/contracts/project.dart';
import 'package:video_generation_ui/screens/transcribe_audio.dart';
import 'package:video_generation_ui/widgets/audio_player_widget.dart';

class GenerateAudioScreen extends StatefulWidget {
  final String projectId;

  const GenerateAudioScreen({super.key, required this.projectId});

  @override
  State<GenerateAudioScreen> createState() => _GenerateAudioScreenState();
}

class _GenerateAudioScreenState extends State<GenerateAudioScreen> {
  late final String projectId;
  final ApiService apiService = ApiService();

  String? selectedVoice;
  List<String> voices = [];
  String? audioUrl;

  bool isLoading = true;
  bool _isGeneratingAudio = false;

  @override
  void initState() {
    super.initState();
    projectId = widget.projectId;

    Future.microtask(() async {
      await fetchVoices();
      await getProjectDetails();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchVoices() async {
    try {
      final response = await apiService.getVoices();
      if (mounted) {
        setState(() {
          voices = List<String>.from(response['voices']);
        });
      }
    } catch (e) {
      if (mounted) _showErrorDialog('Failed to fetch voices: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> getProjectDetails() async {
    try {
      final response = await apiService.getProject(projectId);
      final project = Project.fromJson(response['project']);

      if (project.audioPath != null) {
        await fetchSasUrl(projectId);
      }
    } catch (e) {
      if (mounted) _showErrorDialog('Failed to fetch project details: $e');
    }
  }

  Future<void> _generateAudio(String selectedVoice) async {
    if (_isGeneratingAudio) return;

    setState(() => _isGeneratingAudio = true);

    try {
      final response = await apiService.generateAudio(projectId);
      if (response['success']) {
        await fetchSasUrl(projectId);
      } else if (mounted) {
        _showErrorDialog('Failed to generate audio.');
      }
    } catch (e) {
      if (mounted) _showErrorDialog('Error during audio generation: $e');
    } finally {
      if (mounted) {
        setState(() => _isGeneratingAudio = false);
      }
    }
  }

  Future<void> fetchSasUrl(String projectId) async {
    try {
      final sasResponse = await apiService.getSasUrlForAudio(projectId);
      if (sasResponse['success']) {
        if (mounted) {
          setState(() {
            audioUrl = sasResponse['sas_url'];
          });
        }
      } else if (mounted) {
        _showErrorDialog('Failed to fetch audio SAS URL.');
      }
    } catch (e) {
      if (mounted) _showErrorDialog('Error retrieving SAS URL: $e');
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return; // Prevent showing dialog after widget is disposed
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Generating Audio... Please wait',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ad Placeholder (To be configured)',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Generate Audio')),
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : voices.isEmpty
                  ? const Center(child: Text('No voices available'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Center(
                            child: Text(
                              'Pick a voice:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.separated(
                              separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.grey),
                              itemCount: voices.length,
                              itemBuilder: (context, index) {
                                final voice = voices[index];
                                final isSelected = selectedVoice == voice;
                                return ListTile(
                                  title: Text(
                                    voice,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Colors.blue : Colors.black,
                                    ),
                                  ),
                                  leading: Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: isSelected ? Colors.blue : Colors.grey,
                                  ),
                                  onTap: () {
                                    setState(() => selectedVoice = voice);
                                  },
                                );
                              },
                            ),
                          ),
                          ElevatedButton(
                            onPressed: selectedVoice != null && !_isGeneratingAudio
                                ? () => _generateAudio(selectedVoice!)
                                : null,
                            child: const Text('Generate Audio'),
                          ),
                          if (audioUrl != null) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: AudioPlayerWidget(audioUrl: audioUrl!),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TranscribeAudioScreen(projectId: projectId),
                                  ),
                                );
                              },
                              child: const Text('Transcribe Audio'),
                            ),
                          ],
                        ],
                      ),
                    ),
          if (_isGeneratingAudio) _buildLoadingOverlay(),
        ],
      ),
    );
  }
}
