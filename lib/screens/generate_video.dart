import 'package:flutter/material.dart';
import 'package:video_generation_ui/contracts/project.dart';
import 'package:video_player/video_player.dart';
import 'package:video_generation_ui/api.dart'; // Assuming this API has generateVideo and getProject functions

class GenerateVideoScreen extends StatefulWidget {
  final String projectId;

  const GenerateVideoScreen({super.key, required this.projectId});

  @override
  State<GenerateVideoScreen> createState() => _GenerateVideoScreenState();
}

class _GenerateVideoScreenState extends State<GenerateVideoScreen> {
  late ApiService apiService;
  bool isLoading = true;
  String? generatedVideoPath;
  String? sasURL;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    _loadProject();
  }

  // Load project to check if video is already generated
  Future<void> _loadProject() async {
    try {
      var response = await apiService.getProject(widget.projectId);
      var project = Project.fromJson(response['project']);
      if (project.generatedVideoPath != null &&
          project.generatedVideoPath != '') {
        // Video already generated, retrieve the SAS URL
        response = await apiService.getSasUrlForVideo(project.id);
        if (response['success'] == true) {
          setState(() {
            print(project.generatedVideoPath);
            print(response['sasURL']);
            generatedVideoPath = project.generatedVideoPath;
            sasURL = response['sasURL'];
            isLoading = false;
            _initializeVideoPlayer();
          });
        }
        ;
      } else {
        // If video not generated, initiate the video generation process
        _generateVideo();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showError(e.toString());
    }
  }

  // Call the API to generate the video
  Future<void> _generateVideo() async {
    try {
      final response = await apiService.generateVideo(widget.projectId);
      if (response['success'] == true) {
        // Video successfully generated, reload project
        _loadProject();
      } else {
        showError('Failed to generate video.');
      }
    } catch (e) {
      showError(e.toString());
    }
  }

  // Initialize the video player with the SAS URL
  void _initializeVideoPlayer() {
    if (sasURL != null) {
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(sasURL!))
            ..initialize().then((_) {
              setState(() {});
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
  void dispose() {
    super.dispose();
    _videoPlayerController
        ?.dispose(); // Don't forget to dispose of the video player
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Video'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : generatedVideoPath != null && sasURL != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Video Generated Successfully!'),
                    const SizedBox(height: 20),
                    Text('Video Path: $generatedVideoPath'),
                    const SizedBox(height: 20),
                    Text('SAS URL: $sasURL'),
                    const SizedBox(height: 20),
                    _videoPlayerController != null &&
                            _videoPlayerController!.value.isInitialized
                        ? Column(
                            children: [
                              AspectRatio(
                                aspectRatio:
                                    _videoPlayerController!.value.aspectRatio,
                                child: VideoPlayer(_videoPlayerController!),
                              ),
                              VideoProgressIndicator(
                                _videoPlayerController!,
                                allowScrubbing: true,
                              ),
                              IconButton(
                                icon: Icon(
                                  _videoPlayerController!.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (_videoPlayerController!
                                        .value.isPlaying) {
                                      _videoPlayerController!.pause();
                                    } else {
                                      _videoPlayerController!.play();
                                    }
                                  });
                                },
                              ),
                            ],
                          )
                        : const CircularProgressIndicator(),
                  ],
                )
              : const Center(
                  child: Text('No video generated yet.'),
                ),
    );
  }
}
