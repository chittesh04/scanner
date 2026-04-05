import 'package:flutter_riverpod/flutter_riverpod.dart';

final scanControllerProvider =
    StateNotifierProvider.autoDispose<ScanController, ScanViewState>((ref) {
  return ScanController();
});

class ScanController extends StateNotifier<ScanViewState> {
  ScanController() : super(const ScanViewState());

  void setAutoMode(bool enabled) {
    state = state.copyWith(autoMode: enabled);
  }

  void setTorchEnabled(bool enabled) {
    state = state.copyWith(torchEnabled: enabled);
  }
}

class ScanViewState {
  const ScanViewState({
    this.autoMode = true,
    this.torchEnabled = false,
  });

  final bool autoMode;
  final bool torchEnabled;

  ScanViewState copyWith({
    bool? autoMode,
    bool? torchEnabled,
  }) {
    return ScanViewState(
      autoMode: autoMode ?? this.autoMode,
      torchEnabled: torchEnabled ?? this.torchEnabled,
    );
  }
}
