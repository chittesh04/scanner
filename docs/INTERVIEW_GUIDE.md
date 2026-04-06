# Interview Guide: SmartScan

## System Design Narrative
SmartScan is designed as an offline-first mobile document system where the UI remains responsive while long-running processing (OCR/indexing/export) is isolated into dedicated layers.

### Design Priorities
1. Reliability over demo-speed shortcuts
2. Clear boundaries between UI, domain logic, and infrastructure
3. Recoverable failures and observable behavior

## 30-Second Pitch
SmartScan is a modular Flutter scanner with clean architecture and production-aware pipelines. It captures documents, stores them securely, runs OCR asynchronously, and exports data-rich formats while keeping UI state deterministic and resilient.

## 2-Minute Interview Walkthrough
- Presentation (`mobile_app`) uses Riverpod for predictable state.
- Write paths are encapsulated as use-cases to keep UI free from low-level repository concerns.
- Engine (`core_engine`) provides scan and OCR processing interfaces with concrete ML Kit implementations.
- Persistence (`database`) uses Isar with transactional writes for document/page/OCR integrity.
- Infrastructure (`services`) handles encrypted file I/O, background job scheduling, and indexing.
- Data flow is: scan -> encrypted file write -> metadata persist -> background OCR -> indexed summary -> export.

## Trade-Offs to Discuss
- Chose local-first consistency over immediate cloud dependence.
- Added modular overhead to gain maintainability and interview-level clarity.
- Prioritized debuggability with structured logging in each subsystem.

## Suggested Technical Deep-Dives
- Background job idempotency and retry semantics.
- Data consistency guarantees (what is atomic vs eventually consistent).
- Performance strategy for document list rendering and OCR summary generation.
- Security boundaries for key management and encrypted storage.

## Tough Follow-Up Questions
1. How would you support collaborative editing?
- Add conflict-aware sync and operation logs in services layer, keep local repo authoritative.

2. How would you improve OCR quality?
- Add language-aware routing, confidence thresholds, and optional post-processing use-cases.

3. Where are the scaling bottlenecks?
- OCR throughput, large image memory pressure, and full-list stream mapping; mitigate with incremental indexing/pagination.