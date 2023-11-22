import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_gallery_app/bloc/media_selector_bloc/media_selector_bloc.dart';
import 'package:my_gallery_app/bloc/media_selector_bloc/media_selector_events.dart';
import 'package:my_gallery_app/bloc/media_selector_bloc/media_selector_states.dart';
import 'package:my_gallery_app/widget/image_item_widget.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaSelectorPage extends StatefulWidget {
  const MediaSelectorPage({Key? key}) : super(key: key);

  @override
  MediaSelectorPageState createState() => MediaSelectorPageState();
}

class MediaSelectorPageState extends State<MediaSelectorPage> {
  /// Customize your own filter options.
  final FilterOptionGroup _filterOptionGroup = FilterOptionGroup(
    imageOption: const FilterOption(
      sizeConstraint: SizeConstraint(ignoreSize: true),
    ),
  );

  @override
  void initState() {
    super.initState();
    _requestAssets();
  }

  final MediaSelectorBloc _bloc = MediaSelectorBloc();
  ValueNotifier<List<String>> selectedEntities =
      ValueNotifier<List<String>>([]);
  List<String> selectedFilePaths = [];

  AssetPathEntity? _path;
  List<AssetEntity>? _entities;

  Future<void> _requestAssets() async {
    _bloc.add(RequestMediaEvent(
      filterOptionGroup: _filterOptionGroup,
      sizePerPage: 30,
    ));
  }

  Future<void> _loadMoreAsset(LoadedMediaSelectorState state) async {
    _bloc.add(LoadMoreMediaRequestEvent(currentLoadedState: state));
  }

  Widget _buildBody(BuildContext context, MediaSelectorState state) {
    if (state is LoadingMediaSelectorState) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (state is LoadedMediaSelectorState) {
      _path = state.path;
      _entities = state.entities;
      if (_path == null) {
        return const Center(child: Text('Request paths first.'));
      }
      if (_entities?.isNotEmpty != true) {
        return const Center(child: Text('No assets found on this device.'));
      }
      return GridView.custom(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        childrenDelegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            if (index == state.entities!.length - 8 &&
                !state.isLoadingMore &&
                state.hasMoreToLoad) {
              _loadMoreAsset(state);
            }

            return ValueListenableBuilder<List<String>>(
                valueListenable: selectedEntities,
                builder: (context, value, _) {
                  final AssetEntity entity = state.entities![index];
                  bool isSelected = value.contains(entity.id);
                  return GestureDetector(
                    onTap: () async {
                      List<String> newList = selectedEntities.value;
                      File? file = await entity.file;
                      if (!isSelected) {
                        newList.add(entity.id);
                        if (file != null) {
                          selectedFilePaths.add(file.path);
                        }
                      } else {
                        newList.remove(entity.id);
                        if (file != null &&
                            selectedFilePaths.contains(file.path)) {
                          selectedFilePaths.remove(file.path);
                        }
                      }
                      selectedEntities.value = List.from(newList);
                      print(selectedFilePaths);
                    },
                    child: Stack(
                      children: [
                        ImageItemWidget(
                          key: ValueKey<int>(index),
                          entity: entity,
                          option: const ThumbnailOption(
                              size: ThumbnailSize.square(200)),
                        ),
                        if (isSelected)
                          Positioned.fill(
                            child: Container(
                              color: Colors.white.withOpacity(0.5),
                              child: const Icon(
                                Icons.check_box,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                });
          },
          childCount: state.entities!.length,
          findChildIndexCallback: (Key key) {
            // Re-use elements.
            if (key is ValueKey<int>) {
              return key.value;
            }
            return null;
          },
        ),
      );
    }
    if (state is FailedLoadingMediaSelectorState) {
      return Center(
        child: Text(state.message),
      );
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Device Photos')),
        body: BlocBuilder<MediaSelectorBloc, MediaSelectorState>(
            builder: (context, state) {
          return Column(
            children: <Widget>[
              Expanded(child: _buildBody(context, state)),
            ],
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: _requestAssets,
          child: const Icon(Icons.developer_board),
        ),
      ),
    );
  }
}
