import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/widgets.dart';
import '../../data/media_store.dart';

void openPhotoViewer(BuildContext context, List<String> photos, int index) {
  Navigator.of(context).push(PageRouteBuilder(
    opaque: false,
    barrierColor: Colors.black,
    pageBuilder: (_, _, _) => _PhotoViewer(photos: photos, index: index),
    transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
  ));
}

class _PhotoViewer extends StatefulWidget {
  const _PhotoViewer({required this.photos, required this.index});
  final List<String> photos;
  final int index;

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late final _page = PageController(initialPage: widget.index);
  late int _current = widget.index;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              controller: _page,
              itemCount: widget.photos.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (_, i) => InteractiveViewer(
                maxScale: 4,
                child: Center(
                  child: Hero(
                    tag: 'photo-${widget.photos[i]}',
                    child: Image(image: MediaStore.instance.photo(widget.photos[i]), fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    CircleButton(icon: Ph.x, onTap: () => Navigator.pop(context), background: Colors.white24, color: Colors.white),
                    const Spacer(),
                    if (widget.photos.length > 1)
                      Text('${_current + 1} / ${widget.photos.length}', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
