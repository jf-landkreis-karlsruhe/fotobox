import 'package:flutter/material.dart';
import 'package:fotobox_frontend/src/model/session_model.dart';
import 'package:watch_it/watch_it.dart';

class ThumbnailImagesView extends StatelessWidget with WatchItMixin {
  const ThumbnailImagesView({
    super.key,
    required this.currentSession,
  });

  final SessionModel currentSession;

  @override
  Widget build(BuildContext context) {
    var images = watchPropertyValue(
      (SessionModel model) => model.images,
      target: currentSession,
    );

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: images
          .map((image) => SizedBox(
                width: 150,
                height: 80,
                child: Image.network(image.path),
              ))
          .toList(),
    );
  }
}
