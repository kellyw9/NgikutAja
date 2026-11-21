import 'package:flutter/material.dart';

class PhotoThumb extends StatelessWidget {
  const PhotoThumb({
    super.key,
    this.url,
    this.size = 56,
    this.borderRadius = 8,
  });

  final String? url;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final placeholder = _Placeholder(size: size);
    final photoUrl = url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: (photoUrl == null || photoUrl.isEmpty)
            ? placeholder
            : Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => placeholder,
                loadingBuilder: (context, child, progress) {
                  return progress == null ? child : placeholder;
                },
              ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: size * 0.45,
        color: Colors.grey.shade600,
      ),
    );
  }
}
