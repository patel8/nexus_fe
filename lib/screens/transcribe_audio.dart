import 'package:flutter/material.dart';
import 'package:video_generation_ui/api.dart';
import 'package:video_generation_ui/contracts/transcription.dart';
import 'package:video_generation_ui/screens/generate_video.dart';

class TranscribeAudioScreen extends StatefulWidget {
  final String projectId;

  const TranscribeAudioScreen({super.key, required this.projectId});

  @override
  State<TranscribeAudioScreen> createState() => _TranscribeAudioScreenState();
}

class _TranscribeAudioScreenState extends State<TranscribeAudioScreen> {
  late ApiService apiService;
  Transcription transcription = Transcription();
  bool isLoading = true;
  bool isReplacingImage = false; // To track the image replacement loading state
  int? _expandedIndex; // To track the expanded segment

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    _fetchTranscription();
  }

  // Fetch transcription and if not available, initiate transcription
  Future<void> _fetchTranscription() async {
    try {
      final response = await apiService.getTranscription(widget.projectId);
      if (response['transcription'] == null ||
          response['transcription'] == "") {
        _startTranscription();
      } else {
        setState(() {
          transcription = Transcription.fromJson(response['transcription']);
          for (Segment segment in transcription.segments!) {
            print(segment.imagePath);
          }
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showError(e.toString());
    }
  }

  // Start transcription if not available
  Future<void> _startTranscription() async {
    try {
      final response = await apiService.transcribeAudio(widget.projectId);
      if (response['success'] == true) {
        _fetchTranscription();
      } else {
        showError('Failed to start transcription.');
      }
    } catch (e) {
      showError(e.toString());
    }
  }

  // Replace image for a specific transcription segment
  Future<void> _replaceImage(int transcriptionIndex) async {
    setState(() {
      isReplacingImage =
          true; // Set the loading state to true when the request starts
    });

    try {
      final response =
          await apiService.replaceImage(widget.projectId, transcriptionIndex);
      if (response['success'] == true) {
        setState(() {
          // Reload the transcription after replacing the image
          isReplacingImage =
              false; // Set the loading state to false after completion
        });
        _fetchTranscription(); // Reload the transcription data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image successfully replaced!')),
        );
      } else {
        showError('Failed to replace image.');
        setState(() {
          isReplacingImage = false; // Reset loading state if failed
        });
      }
    } catch (e) {
      showError(e.toString());
      setState(() {
        isReplacingImage = false; // Reset loading state if error occurs
      });
    }
  }

  // Show error messages if needed
  void showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Transcription'),
      ),
      body: isReplacingImage
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Replace image. Please wait.'),
                  const SizedBox(height: 20),
                  const Placeholder(), // Placeholder for ad space
                ],
              ),
            )
          : ListView.builder(
              itemCount: transcription.segments?.length ?? 0,
              itemBuilder: (context, index) {
                final segment = transcription.segments![index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _expandedIndex = (_expandedIndex == index) ? null : index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: _expandedIndex == index
                          ? Colors.blue.shade100
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                segment.text ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (_expandedIndex == index) ...[
                          const SizedBox(height: 10),
                          Image.network(
                            segment.imagePath!,
                            width: 100,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start: ${segment.start ?? 0.0} - End: ${segment.end ?? 0.0}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          // Button to replace the image for this segment
                          ElevatedButton(
                            onPressed: isReplacingImage
                                ? null
                                : () {
                                    _replaceImage(index);
                                  },
                            child: isReplacingImage
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text('Replace Image'),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Future functionality for generating the video will go here
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    GenerateVideoScreen(projectId: widget.projectId),
              ),
            );
          },
          child: const Text('Generate Video'),
        ),
      ),
    );
  }
}
