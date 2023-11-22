import 'package:photo_manager/photo_manager.dart';

abstract class MediaSelectorState {}

class InitialMediaSelectorState extends MediaSelectorState {}

class LoadingMediaSelectorState extends MediaSelectorState {}

class LoadedMediaSelectorState extends MediaSelectorState {
  AssetPathEntity? path;
  List<AssetEntity>? entities;
  int totalEntitiesCount = 0;
  int page = 0;
  bool isLoadingMore = false;
  bool hasMoreToLoad = true;

  LoadedMediaSelectorState(
      {this.path,
      this.entities,
      this.totalEntitiesCount = 0,
      this.page = 0,
      this.isLoadingMore = false,
      this.hasMoreToLoad = false});

  LoadedMediaSelectorState copyWith({
    AssetPathEntity? path,
    List<AssetEntity>? entities,
    int? totalEntitiesCount,
    int? page,
    bool? isLoadingMore,
    bool? hasMoreToLoad,
  }) {
    return LoadedMediaSelectorState(
      path: path ?? this.path,
      hasMoreToLoad: hasMoreToLoad ?? this.hasMoreToLoad,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      totalEntitiesCount:  totalEntitiesCount ?? this.totalEntitiesCount,
      page: page ?? this.page,
      entities: entities ?? this.entities,
    );
  }
}

class FailedLoadingMediaSelectorState extends MediaSelectorState {
  String message;

  FailedLoadingMediaSelectorState({required this.message});
}
