import "dart:io";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:image_picker/image_picker.dart";
import "package:path_provider/path_provider.dart";

final profilePhotoRepositoryProvider = Provider<ProfilePhotoRepository>((ref) {
  return ProfilePhotoRepository(ImagePicker());
});

class ProfilePhotoRepository {
  ProfilePhotoRepository(this._imagePicker);

  final ImagePicker _imagePicker;

  Future<String?> pickProfilePhotoPath() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1440,
      maxHeight: 1440,
      imageQuality: 92,
    );

    return pickedFile?.path;
  }

  Future<String> persistProfilePhoto(
    String sourcePath, {
    String? previousPath,
  }) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw FileSystemException("Selected profile photo not found.", sourcePath);
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final profileDirectory = Directory(
      "${documentsDirectory.path}${Platform.pathSeparator}profile",
    );
    await profileDirectory.create(recursive: true);

    final extension = _extensionFor(sourcePath);
    final persistedPath =
        "${profileDirectory.path}${Platform.pathSeparator}profile_photo$extension";

    if (sourceFile.path != persistedPath) {
      await sourceFile.copy(persistedPath);
    }

    if (previousPath != null &&
        previousPath.isNotEmpty &&
        previousPath != persistedPath) {
      final previousFile = File(previousPath);
      if (await previousFile.exists()) {
        await previousFile.delete();
      }
    }

    return persistedPath;
  }

  String _extensionFor(String path) {
    final dotIndex = path.lastIndexOf(".");
    if (dotIndex == -1 || dotIndex == path.length - 1) {
      return ".jpg";
    }

    return path.substring(dotIndex);
  }
}
