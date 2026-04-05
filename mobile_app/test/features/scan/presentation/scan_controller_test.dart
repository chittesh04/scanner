import 'package:flutter_test/flutter_test.dart';
import 'package:smartscan/features/scan/presentation/scan_controller.dart';

void main() {
  group('ScanController', () {
    test('auto mode toggle updates state', () {
      final controller = ScanController();

      expect(controller.state.autoMode, isTrue);

      controller.setAutoMode(false);
      expect(controller.state.autoMode, isFalse);

      controller.setAutoMode(true);
      expect(controller.state.autoMode, isTrue);
    });

    test('torch toggle updates state', () {
      final controller = ScanController();

      expect(controller.state.torchEnabled, isFalse);

      controller.setTorchEnabled(true);
      expect(controller.state.torchEnabled, isTrue);

      controller.setTorchEnabled(false);
      expect(controller.state.torchEnabled, isFalse);
    });
  });
}
