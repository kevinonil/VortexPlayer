import 'package:photo_manager/photo_manager.dart';

class MediaService {
  Future<bool> requestPermission() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();

    return permission.isAuth || permission.hasAccess;
  }

  Future<List<AssetEntity>> getVideos() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();

    if (!permission.hasAccess) {
      return [];
    }

    final List<AssetPathEntity> albums =
        await PhotoManager.getAssetPathList(
      type: RequestType.video,
    );

    List<AssetEntity> videos = [];

    for (final album in albums) {
      final List<AssetEntity> assets =
          await album.getAssetListPaged(
        page: 0,
        size: 1000,
      );

      videos.addAll(assets);
    }

    return videos;
  }

  Future<List<AssetEntity>> getAudios() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();

    if (!permission.hasAccess) {
      return [];
    }

    final List<AssetPathEntity> albums =
        await PhotoManager.getAssetPathList(
      type: RequestType.audio,
    );

    List<AssetEntity> audios = [];

    for (final album in albums) {
      final List<AssetEntity> assets =
          await album.getAssetListPaged(
        page: 0,
        size: 1000,
      );

      audios.addAll(assets);
    }

    return audios;
  }
}
