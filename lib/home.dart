import 'package:flutter/material.dart';
import 'package:video_generation_ui/screens/project_screen.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Generation App'),
        centerTitle: true,
      ),
      body: const ProjectScreen()
    );
  }
}
