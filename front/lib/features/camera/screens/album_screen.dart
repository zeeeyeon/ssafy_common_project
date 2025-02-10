import 'package:flutter/material.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/camera/data/models/album_model.dart';
import 'package:kkulkkulk/features/camera/view_models/album_view_model.dart';
import 'package:kkulkkulk/features/camera/providers/camera_providers.dart';
import 'package:kkulkkulk/features/camera/screens/video_player_screen.dart';
import 'package:kkulkkulk/common/utils/color_converter.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class AlbumScreen extends ConsumerStatefulWidget {
  const AlbumScreen({super.key});

  @override
  ConsumerState<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends ConsumerState<AlbumScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: ref.read(currentTabProvider),
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(currentTabProvider.notifier).state = _tabController.index;
        _fetchAlbumData(isSuccess: _tabController.index == 0);
      }
    });
    _fetchAlbumData(isSuccess: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAlbumData({required bool isSuccess}) async {
    final dateStr =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
    await ref.read(albumViewModelProvider.notifier).fetchAlbum(
          date: dateStr,
          isSuccess: isSuccess,
        );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _fetchAlbumData(isSuccess: _tabController.index == 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '앨범',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_rounded),
            iconSize: 30,
            onPressed: () {
              context.go('/camera');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '성공'),
              Tab(text: '실패'),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: _selectDate,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${selectedDate.year}. ${selectedDate.month}. ${selectedDate.day}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVideoGrid(isSuccess: true),
                _buildVideoGrid(isSuccess: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoGrid({required bool isSuccess}) {
    return Consumer(
      builder: (context, ref, child) {
        final albumState = ref.watch(albumViewModelProvider);

        return albumState.when(
          data: (albumResponse) {
            if (albumResponse == null || albumResponse.albumObject.isEmpty) {
              return const Center(
                child: Text('기록된 영상이 없습니다'),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: albumResponse.albumObject.length,
              itemBuilder: (context, index) {
                final item = albumResponse.albumObject[index];
                return _VideoGridItem(
                  albumItem: item,
                  selectedDate:
                      "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('오류가 발생했습니다: $error'),
          ),
        );
      },
    );
  }
}

class _VideoGridItem extends StatelessWidget {
  final AlbumItem albumItem;
  final String selectedDate;

  const _VideoGridItem({
    required this.albumItem,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              albumItem.url,
              selectedDate,
              albumItem.isSuccess,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            albumItem.thumbnailUrl.isNotEmpty
                ? Image.network(
                    albumItem.thumbnailUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.video_library, size: 40),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.video_library, size: 40),
                  ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: ColorConverter.fromString(albumItem.color),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  albumItem.level,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
