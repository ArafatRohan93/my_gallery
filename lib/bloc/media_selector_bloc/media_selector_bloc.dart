import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_gallery_app/bloc/media_selector_bloc/media_selector_events.dart';
import 'package:my_gallery_app/bloc/media_selector_bloc/media_selector_states.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaSelectorBloc extends Bloc<MediaSelectorEvent, MediaSelectorState> {
  MediaSelectorBloc() : super(InitialMediaSelectorState()) {
    on<RequestMediaEvent>((event, emit) async {
      emit(LoadingMediaSelectorState());
      final PermissionState permissionState =
          await PhotoManager.requestPermissionExtend();
      if (!permissionState.hasAccess) {
        emit(FailedLoadingMediaSelectorState(message: 'Failed denied'));
        return;
      }

      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        onlyAll: true,
        filterOption: event.filterOptionGroup,
      );

      if (paths.isEmpty) {
        emit(FailedLoadingMediaSelectorState(message: 'Paths not found'));
        return;
      }

      var path = paths.first;
      int totalEntitiesCount = await path.assetCountAsync;
      final List<AssetEntity> entities = await path.getAssetListPaged(
        page: 0,
        size: event.sizePerPage,
      );
      bool hasMoreToLoad = entities.length < totalEntitiesCount;

      emit(
        LoadedMediaSelectorState(
          path: path,
          entities: entities,
          hasMoreToLoad: hasMoreToLoad,
          page: 0,
          isLoadingMore: false,
          totalEntitiesCount: totalEntitiesCount,
        ),
      );
    });
    on<LoadMoreMediaRequestEvent>((event, emit) async {
      final List<AssetEntity> entities = await event.currentLoadedState.path!
          .getAssetListPaged(
              page: event.currentLoadedState.page + 1, size: event.sizePerPage);
      List<AssetEntity> overallEntities =
          event.currentLoadedState.entities ?? [];
      overallEntities.addAll(entities);
      emit(
        event.currentLoadedState.copyWith(
          entities: overallEntities,
          page: event.currentLoadedState.page + 1,
          isLoadingMore: false,
          hasMoreToLoad: overallEntities.length <
              event.currentLoadedState.totalEntitiesCount,
        ),
      );
    });
  }
}
