import '../domain/sync_job.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class CloudSyncService {
  final _googleSignIn = GoogleSignIn(scopes: [drive.DriveApi.driveFileScope]);

  Future<void> enqueue(SyncJob job) async {
    if (job.provider != SyncProvider.googleDrive) {
      return;
    }

    var account = _googleSignIn.currentUser;
    if (account == null) {
      try {
        account = await _googleSignIn.signInSilently();
      } catch (_) {}
    }
    
    account ??= await _googleSignIn.signIn();
    
    if (account == null) {
      throw StateError('Google SignIn failed or aborted.');
    }

    final authHeaders = await account.authHeaders;
    final client = _GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(client);

    try {
      final fileToUpload = drive.File()
        ..name = '${job.documentId}.pdf'
        ..description = 'SmartScan Document sync'
        ..appProperties = {'documentId': job.documentId};

      final stubStream = Stream.value(utf8.encode('stub file'));
      final media = drive.Media(stubStream, 9);

      await driveApi.files.create(
        fileToUpload,
        uploadMedia: media,
      );
    } finally {
      client.close();
    }
  }
}
