import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilpsetu/core/database/database_provider.dart';
import 'package:shilpsetu/features/enquiries/data/repository/enquiries_repository_impl.dart';
import 'package:shilpsetu/features/enquiries/domain/models/enquiry_item.dart';
import 'package:shilpsetu/features/enquiries/domain/repository/enquiries_repository.dart';

class EnquiriesState {
  const EnquiriesState({
    required this.enquiries,
    required this.isLoading,
    this.errorMessage,
    this.activePlayingId,
  });

  factory EnquiriesState.initial() => const EnquiriesState(
        enquiries: [],
        isLoading: true,
      );

  final List<EnquiryItem> enquiries;
  final bool isLoading;
  final String? errorMessage;
  final String? activePlayingId;

  int get unreadCount => enquiries.where((e) => e.isUnread).length;

  EnquiriesState copyWith({
    List<EnquiryItem>? enquiries,
    bool? isLoading,
    String? errorMessage,
    String? activePlayingId,
  }) {
    return EnquiriesState(
      enquiries: enquiries ?? this.enquiries,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      activePlayingId: activePlayingId ?? this.activePlayingId,
    );
  }
}

final enquiriesRepositoryProvider = Provider<EnquiriesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return EnquiriesRepositoryImpl(database: db);
});

class EnquiriesController extends StateNotifier<EnquiriesState> {
  EnquiriesController({required EnquiriesRepository repository})
      : _repository = repository,
        super(EnquiriesState.initial()) {
    loadEnquiries();
  }

  final EnquiriesRepository _repository;

  Future<void> loadEnquiries() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.fetchEnquiries();
      state = state.copyWith(enquiries: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load enquiries: $e',
      );
    }
  }

  Future<void> markRead(String id) async {
    await _repository.markAsRead(id);
    final updated = state.enquiries.map((e) {
      return e.id == id ? e.copyWith(status: EnquiryStatus.read) : e;
    }).toList();
    state = state.copyWith(enquiries: updated);
  }

  Future<void> accept(String id) async {
    await _repository.acceptEnquiry(id);
    final updated = state.enquiries.map((e) {
      return e.id == id ? e.copyWith(status: EnquiryStatus.accepted) : e;
    }).toList();
    state = state.copyWith(enquiries: updated);
  }

  void setActivePlaying(String? id) {
    state = state.copyWith(activePlayingId: id);
  }
}

final enquiriesControllerProvider =
    StateNotifierProvider<EnquiriesController, EnquiriesState>((ref) {
  final repository = ref.watch(enquiriesRepositoryProvider);
  return EnquiriesController(repository: repository);
});
