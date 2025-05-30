import 'package:flutter/material.dart';
import 'package:flutterproject/common/styles/widgets/appbar/appbar.dart';
import 'package:video_player/video_player.dart';

class VideoSupportScreen extends StatefulWidget {
  final String videoUrl;

  VideoSupportScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoSupportScreenState createState() => _VideoSupportScreenState();
}
class _VideoSupportScreenState extends State<VideoSupportScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying =false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose(); // Giải phóng bộ nhớ khi không sử dụng nữa
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppAppBar(showBackArrow: true,title: Text('Video Support')),
            Center(
              child: _isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const CircularProgressIndicator(), // Hiển thị khi video đang load
            ),
          ],
        ),
      ),
      floatingActionButton: _isInitialized
        ? FloatingActionButton(
          onPressed: () {
            setState(() {
              if (_controller.value.isPlaying) {
                _controller.pause(); // Nếu đang phát thì tạm dừng
                _isPlaying = false;
              } else {
                _controller.play(); // Nếu tạm dừng thì tiếp tục phát
                _isPlaying = true;
              }
            });
          },
          child: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        )
      : null, // Nếu video chưa được khởi tạo thì không hiển thị nút
    );
  }
}