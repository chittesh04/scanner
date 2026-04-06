# SmartScan System Design

## 1) Scope and Goal
SmartScan is an offline-first document system that runs fully on-device today, but is structured so it can evolve into a cloud-connected product.

Primary lifecycle:
`capture -> process -> OCR -> store -> index -> search -> export -> sync`

## 2) Current Architecture (As Implemented)
```text
[Flutter UI / Riverpod]
        |
        v
[Use Cases - mobile_app/features/document/domain/usecases]
        |
        v
[Repository Contract - models]
        |
        v
[Repository Impl - database]
   |               |
   v               v
[Isar DB]     [Core Engine OCR/Scan]
   |               |
   +-------> [Services Layer]
              - encrypted file storage
              - background work manager
              - search index service
```

## 3) End-to-End Data Flow
1. Capture:
- Scanner service captures pages and writes encrypted files.
2. Process:
- Page metadata is stored in Isar with OCR status `pending`.
3. OCR:
- Background job picks pending pages, processes in chunks, retries transient failures.
4. Store:
- OCR blocks and full text are stored atomically per page update.
5. Index:
- Search index service reads persisted text for lookup.
6. Search:
- UI queries index/repository and renders matching summaries.
7. Export:
- PDF/DOCX/XLSX services read persisted data and produce artifacts.
8. Sync (future):
- Device event log is uploaded and reconciled with server state.

## 4) Current Bottlenecks and Failure Points
### Bottlenecks
- OCR throughput is CPU-bound on mobile hardware.
- Document list retrieval can degrade if full scans are mapped for large datasets.
- Large page images can pressure memory on mid-range devices during preview/export.

### Failure Points
- Corrupt or missing image files can break OCR stage if not isolated.
- Background jobs can duplicate work if idempotency is weak.
- Partial failures between file IO and metadata updates can create inconsistencies.

## 5) Scalability Strategy
### 5.1 Local Scale (10K-100K documents per device)
- Cursor pagination using `updatedAt` to avoid full-list UI materialization.
- Incremental OCR processing with chunked background execution.
- Eventual indexing model: document remains usable even while OCR is incomplete.

### 5.2 Cloud Extension (Optional Layer)
Proposed sync architecture:
```text
[Device Isar + File Store]
        |
   [Sync Outbox]
   (create/update/delete events with monotonic version)
        |
        v
[Sync API Gateway] -> [Document Service] -> [Object Store + Search Index]
        ^
        |
   [Conflict Resolver]
```

Sync principles:
- Local-first source of truth for UX responsiveness.
- Outbox pattern for resilient upload retries.
- Idempotent server writes via operation IDs.
- Pull-based delta sync using `lastSyncedAt` + cursor token.

### 5.3 Conflict Resolution
- Metadata fields: Last-write-wins with server timestamp.
- Page edits/reorder: operation-based merge with vector/version checks.
- Deletion vs update: tombstone policy where delete wins unless explicitly restored.

### 5.4 Background Queue Design
- Queue unit: page-level OCR job (`documentId`, `pageId`, `attempt`).
- Idempotency key: `{documentId}:{pageId}:{contentHash}`.
- Retry policy: exponential backoff with max attempts.
- Dead-letter handling: mark failed, surface in UI for manual retry.

## 6) Robustness and Fault Tolerance
### Implemented Hardening
- Retry policy for transient OCR failures.
- Chunked OCR background execution and re-queue for remaining pages.
- Structured logging for app/engine/db/services.
- Guarded database open path and transactional writes.

### Recommended Next Steps
- Add checksum validation for encrypted page files before OCR.
- Add lightweight repair job for dangling DB references or orphan files.
- Add metrics counters (OCR success rate, average queue latency, sync lag).

## 7) Performance Engineering
### Implemented
- Cursor-based `fetchDocumentsPage()` repository contract.
- Use-case boundary for list retrieval to support lazy/paginated UI evolution.

### Next Optimizations
- Thumbnail-first loading for document lists and detail grids.
- Decode large images in isolate for export/preview heavy paths.
- Cache OCR summaries and invalidate by page `updatedAt`.

## 8) Module Boundaries and Contracts
- `mobile_app`: presentation + orchestration only.
- `core_engine`: scan/OCR processing implementation.
- `database`: persistence + repository implementation.
- `services`: encryption, background scheduling, cross-cutting concerns.
- `models`: stable contracts and shared entities.

Design rule:
- UI depends on use-cases/contracts, not concrete DB or platform services.

## 9) Trade-offs
- Offline-first improves responsiveness and privacy but adds sync complexity.
- Strong modularity improves maintainability but increases boilerplate.
- Eventual consistency (OCR/index/sync) avoids UI blocking but requires clear status UX.

## 10) Interview Discussion Points
### How to scale to millions of users
- Keep on-device local-first UX.
- Introduce stateless sync APIs with outbox + cursor deltas.
- Offload heavy search/OCR analytics to backend pipelines.
- Use tenant-aware storage + partitioned indexes.

### Backend integration changes needed
- Add sync contracts (`operationId`, `entityVersion`, `cursorToken`).
- Build server conflict resolver and audit trail.
- Add observability (tracing, queue metrics, failure dashboards).

### Offline-first trade-off summary
- Pros: speed, resilience in weak network, stronger privacy posture.
- Cons: conflict handling complexity, dual-state reasoning, deferred consistency.
