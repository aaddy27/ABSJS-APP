import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

/// Android 13+ => READ_MEDIA_*
/// Android 10–12 => READ_EXTERNAL_STORAGE
/// iOS / others => return true (permission handler will manage photo library if needed)
Future<bool> ensureMediaPermission({bool needVideo = false, bool needAudio = false}) async {
  if (!Platform.isAndroid) {
    return true;
  }

  // permission_handler maps:
  // - Permission.photos => READ_MEDIA_IMAGES (API 33+)
  // - Permission.videos => READ_MEDIA_VIDEO (API 33+)
  // - Permission.audio  => READ_MEDIA_AUDIO (API 33+)
  // - Permission.storage => READ_EXTERNAL_STORAGE (<= API 32)

  // Pehle Android 13+ specific permissions try karte hain.
  final photosStatus = await Permission.photos.status;
  final isAndroid13Style = photosStatus != PermissionStatus.denied ||
      (await Permission.videos.status) != PermissionStatus.denied ||
      (await Permission.audio.status) != PermissionStatus.denied;

  if (isAndroid13Style) {
    final req = <Permission>[Permission.photos];
    if (needVideo) req.add(Permission.videos);
    if (needAudio) req.add(Permission.audio);

    final results = await req.request();
    return results.values.every((s) => s.isGranted);
  } else {
    // Android 10–12 (API 29–32)
    final status = await Permission.storage.request();
    return status.isGranted;
  }
}
