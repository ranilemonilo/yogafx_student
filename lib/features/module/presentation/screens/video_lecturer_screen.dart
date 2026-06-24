import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';

class VideoLecturerScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final String videoUrl;

  // Data untuk video selanjutnya (bisa null jika ini video terakhir)
  final String? nextVideoId;
  final String? nextVideoTitle;
  final String? nextVideoUrl;

  const VideoLecturerScreen({
    super.key,
    required this.videoId,
    required this.title,
    required this.videoUrl,
    this.nextVideoId,
    this.nextVideoTitle,
    this.nextVideoUrl,
  });

  @override
  State<VideoLecturerScreen> createState() => _VideoLecturerScreenState();
}

class _VideoLecturerScreenState extends State<VideoLecturerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play(); // Auto play saat halaman dibuka
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Fungsi untuk pindah ke video selanjutnya
  void _goToNextVideo() {
    if (widget.nextVideoId != null && widget.nextVideoUrl != null) {
      // Menggunakan pushReplacement agar tumpukan halaman tidak terlalu banyak
      // saat user menekan next berkali-kali
      context.pushReplacementNamed(
        'videoLecturer',
        pathParameters: {'videoId': widget.nextVideoId!},
        queryParameters: {
          'title': widget.nextVideoTitle ?? 'Video Selanjutnya',
          'url': widget.nextVideoUrl!,
          // Note: Di implementasi nyata, Anda mungkin perlu memanggil fungsi provider
          // di sini untuk mendapatkan urutan video setelahnya.
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Lecturer'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Area Pemutar Video
          Container(
            color: Colors.black,
            width: double.infinity,
            child: _isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(_controller),
                  _ControlsOverlay(controller: _controller),
                  VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Colors.blue,
                      bufferedColor: Colors.grey,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                ],
              ),
            )
                : const AspectRatio(
              aspectRatio: 16 / 9,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),

          // 2. Area Detail & Deskripsi
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Simak video penjelasan berikut dengan saksama. Anda dapat melanjutkan ke video berikutnya setelah selesai menonton.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 40),

                  // 3. Tombol Next Video (Hanya tampil jika ada video selanjutnya)
                  if (widget.nextVideoId != null) ...[
                    const Divider(),
                    const SizedBox(height: 10),
                    const Text(
                      "Selanjutnya:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      tileColor: Colors.blue.shade50,
                      leading: const Icon(Icons.play_circle_fill, color: Colors.blue, size: 40),
                      title: Text(
                        widget.nextVideoTitle ?? 'Video Selanjutnya',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: ElevatedButton(
                        onPressed: _goToNextVideo,
                        child: const Text("Next"),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Bantuan untuk Tombol Play/Pause di atas video
class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.value.isPlaying ? controller.pause() : controller.play();
      },
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, VideoPlayerValue value, child) {
              if (!value.isPlaying && value.isInitialized) {
                return const Icon(Icons.play_arrow, color: Colors.white, size: 60.0);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}