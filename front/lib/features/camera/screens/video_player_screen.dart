import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';
import 'package:go_router/go_router.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String selectedDate;
  final bool isSuccess;

  const VideoPlayerScreen(this.videoUrl, this.selectedDate, this.isSuccess,
      {super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });
  }

  void _skipBackward() {
    final newPosition = _controller.value.position - const Duration(seconds: 1);
    _controller.seekTo(newPosition);
  }

  void _skipForward() {
    final newPosition = _controller.value.position + const Duration(seconds: 1);
    _controller.seekTo(newPosition);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: widget.selectedDate,
        showBackButton: true,
        onBackPressed: () => context.go('/album'),
      ),
      body: Stack(
        children: [
          // 비디오 플레이어
          _isInitialized
              ? Container(
                  color: Colors.black,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 48),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: _skipBackward,
              icon: const Icon(
                Icons.replay_10_rounded,
                color: Colors.white,
                size: 35,
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, VideoPlayerValue value, child) {
                return IconButton(
                  onPressed: () {
                    value.isPlaying ? _controller.pause() : _controller.play();
                    setState(() {});
                  },
                  icon: Icon(
                    value.isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                );
              },
            ),
            IconButton(
              onPressed: _skipForward,
              icon: const Icon(
                Icons.forward_10_rounded,
                color: Colors.white,
                size: 35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
