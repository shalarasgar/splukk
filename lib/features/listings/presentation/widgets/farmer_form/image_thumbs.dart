import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';

class NetworkThumb extends StatelessWidget {
  const NetworkThumb({super.key, required this.url, required this.onRemove});

  final String url;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ThumbFrame(
      onRemove: onRemove,
      child: Image.network(url, fit: BoxFit.cover),
    );
  }
}

class LocalThumb extends StatelessWidget {
  const LocalThumb({super.key, required this.path, required this.onRemove});

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ThumbFrame(
      onRemove: onRemove,
      child: FutureBuilder(
        future: XFile(path).readAsBytes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          return Image.memory(snapshot.data!, fit: BoxFit.cover);
        },
      ),
    );
  }
}

class ThumbFrame extends StatelessWidget {
  const ThumbFrame({super.key, required this.child, required this.onRemove});

  final Widget child;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(width: 88, height: 88, child: child),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onRemove,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 18, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
