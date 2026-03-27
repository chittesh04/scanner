enum SyncProvider { googleDrive, dropbox }

class SyncJob {
  const SyncJob({required this.documentId, required this.provider, required this.enqueuedAt});
  final String documentId;
  final SyncProvider provider;
  final DateTime enqueuedAt;
}
