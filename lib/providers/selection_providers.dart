import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selection_providers.g.dart';

class SelectionState {
  final Set<String> selectedIds;
  final bool isActive;

  const SelectionState({this.selectedIds = const {}, this.isActive = false});

  SelectionState copyWith({Set<String>? selectedIds, bool? isActive}) {
    return SelectionState(
      selectedIds: selectedIds ?? this.selectedIds,
      isActive: isActive ?? this.isActive,
    );
  }

  bool isSelected(String id) => selectedIds.contains(id);
  int get selectedCount => selectedIds.length;
  bool get hasSelections => selectedIds.isNotEmpty;
}

@riverpod
class SelectionMode extends _$SelectionMode {
  @override
  SelectionState build() {
    return const SelectionState();
  }

  void enterSelectionMode(String? initialId) {
    state = SelectionState(
      selectedIds: initialId != null ? {initialId} : {},
      isActive: true,
    );
  }

  void exitSelectionMode() {
    state = const SelectionState();
  }

  void toggleSelection(String itemId) {
    final newSelected = Set<String>.from(state.selectedIds);
    if (newSelected.contains(itemId)) {
      newSelected.remove(itemId);
    } else {
      newSelected.add(itemId);
    }

    // If no items selected, exit selection mode
    if (newSelected.isEmpty) {
      exitSelectionMode();
    } else {
      state = state.copyWith(selectedIds: newSelected);
    }
  }

  void selectAll(List<String> itemIds) {
    state = state.copyWith(selectedIds: Set<String>.from(itemIds));
  }

  void deselectAll() {
    exitSelectionMode();
  }
}
