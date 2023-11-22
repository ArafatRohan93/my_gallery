import 'package:my_gallery_app/bloc/media_selector_bloc/media_selector_states.dart';
import 'package:photo_manager/photo_manager.dart';

abstract class MediaSelectorEvent {}

class RequestMediaEvent extends MediaSelectorEvent {
  FilterOptionGroup filterOptionGroup;
  int sizePerPage = 30;

  RequestMediaEvent({
    required this.filterOptionGroup,
    this.sizePerPage = 30,
  });
}

class LoadMoreMediaRequestEvent extends MediaSelectorEvent {
  LoadedMediaSelectorState currentLoadedState;
  int sizePerPage = 30;

  LoadMoreMediaRequestEvent({
    required this.currentLoadedState,
    this.sizePerPage = 30,
  });
}
