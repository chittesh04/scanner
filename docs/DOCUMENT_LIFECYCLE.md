# Document Lifecycle

## End-to-End Flow
1. User opens scan flow from document list/detail.
2. Scanner adapter captures pages and returns image paths.
3. File storage encrypts and persists raw/processed page assets.
4. Repository writes page metadata in Isar transaction.
5. Background OCR job processes pages in pending state.
6. OCR blocks/full text are persisted and searchable summaries update.
7. Export services render PDF/DOCX/XLSX from repository-backed page data.

## Failure Isolation
- Scan page failures are isolated per page where possible.
- OCR failures update per-page status to `failed`; app remains usable.
- Background task failures are logged and retried based on task semantics.
- Export failures do not corrupt persisted data.

## Consistency Model
- Metadata writes are transactional in Isar.
- File cleanup for delete operations is best-effort after metadata delete.
- OCR/indexing is eventually consistent relative to immediate scan completion.