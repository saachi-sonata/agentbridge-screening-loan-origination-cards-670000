# API Documentation

## Endpoints
### Transaction Intake
- **Description**: Collect, validate and normalize transactions from SWIFT Gateway; attach a runId and timestamp for traceability.
- **Type**: Processing

### Planner
- **Description**: Execute planner phase for the Planner-Executor pattern: persist interim state, enforce guardrails, and emit structured JSON results.
- **Type**: Processing

### Executor
- **Description**: Execute executor phase for the Planner-Executor pattern: persist interim state, enforce guardrails, and emit structured JSON results.
- **Type**: Processing

### Limit Control
- **Description**: Limit Control across joined datasets; branch on thresholds using decision gates; write metrics (success/error counts) for observability.
- **Type**: Processing

### Portfolio Check
- **Description**: Portfolio Check across joined datasets; branch on thresholds using decision gates; write metrics (success/error counts) for observability.
- **Type**: Processing

### Settlement
- **Description**: Settlement across joined datasets; branch on thresholds using decision gates; write metrics (success/error counts) for observability.
- **Type**: Processing

### Underwriting
- **Description**: Underwriting across joined datasets; branch on thresholds using decision gates; write metrics (success/error counts) for observability.
- **Type**: Processing

### Operations Handoff
- **Description**: Assemble final payload with status, artifacts, KPIs and audit trail; store to Treasury; return response JSON for the client.
- **Type**: Processing
