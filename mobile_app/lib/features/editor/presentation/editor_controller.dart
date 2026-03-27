import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan/features/editor/domain/page_editor_service.dart';

final pageEditorProvider = Provider<PageEditorService>((_) => PageEditorService());
