import 'package:photo_manager/photo_manager.dart';

class MediaService {
  static const int videoPageSize = 30;

  List<AssetPathEntity> _videoAlbums = [];

  int _currentAlbumIndex = 0;
  int _currentPage = 0;

  bool _videosInitialized = false;

  final Set<String> _loadedVideoIds = {};

  bool get hasMoreVideos {
    return _videosInitialized &&
        _currentAlbumIndex < _videoAlbums.length;
  }

  Future<bool> requestPermission() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();

    return permission.isAuth || permission.hasAccess;
  }

  // ==========================================
  // INITIAL VIDEO LOAD
  // ==========================================

  Future<List<AssetEntity>> getVideos() async {
  print('VIDEO DEBUG: Started');

  final PermissionState permission =
      await PhotoManager.requestPermissionExtend();

  print('VIDEO DEBUG: Permission = ${permission.hasAccess}');

  if (!permission.hasAccess) {
    print('VIDEO DEBUG: Permission denied');
    return [];
  }

  print('VIDEO DEBUG: Getting albums');

  _videoAlbums = await PhotoManager.getAssetPathList(
    type: RequestType.video,
  );

  print('VIDEO DEBUG: Albums = ${_videoAlbums.length}');

  _currentAlbumIndex = 0;
  _currentPage = 0;
  _loadedVideoIds.clear();
  _videosInitialized = true;

  print('VIDEO DEBUG: Loading first page');

  final videos = await loadMoreVideos();

  print('VIDEO DEBUG: Loaded videos = ${videos.length}');

  return videos;
}
  // ==========================================
  // LOAD NEXT VIDEO PAGE
  // ==========================================

  Future<List<AssetEntity>> loadMoreVideos() async {
    if (!_videosInitialized || !hasMoreVideos) {
      return [];
    }

    final List<AssetEntity> newVideos = [];

    while (newVideos.length < videoPageSize &&
        _currentAlbumIndex < _videoAlbums.length) {
      
      final album = _videoAlbums[_currentAlbumIndex];

      final assets = await album.getAssetListPaged(
        page: _currentPage,
        size: videoPageSize,
      );

      _currentPage++;

      for (final asset in assets) {
        if (_loadedVideoIds.add(asset.id)) {
          newVideos.add(asset);
        }

        if (newVideos.length >= videoPageSize) {
          break;
        }
      }

      if (assets.length < videoPageSize) {
        _currentAlbumIndex++;
        _currentPage = 0;
      }
    }

    return newVideos;
  }

  // ==========================================
  // AUDIO LIBRARY
  // ==========================================

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
