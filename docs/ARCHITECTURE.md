# Architecture Documentation

## Overview
This Planner-Executor implements Screening • Loan Origination (Cards) for Banking & Finance use cases.

## Components
1. **Transaction Intake**: Collect, validate and normalize transactions from SWIFT Gateway; attach a runId and timestamp for traceability.
2. **Planner**: Execute planner phase for the Planner-Executor pattern: persist interim state, enforce guardrails, and emit structured JSON results.
3. **Executor**: Execute executor phase for the Planner-Executor pattern: persist interim state, enforce guardrails, and emit structured JSON results.
4. **Limit Control**: Limit Control across joined datasets; branch on thresholds using decision gates; write metrics (success/error counts) for observability.
5. **Portfolio Check**: Portfolio Check across joined datasets; branch on thresholds using decision gates; write metrics (success/error counts) for observability.
6. **Settlement**: Settlement across joined datasets; branch on thresholds using decision gates; write metrics (success/error counts) for observability.
7. **Underwriting**: Underwriting across joined datasets; branch on thresholds using decision gates; write metrics (success/error counts) for observability.
8. **Operations Handoff**: Assemble final payload with status, artifacts, KPIs and audit trail; store to Treasury; return response JSON for the client.

## Data Flow
- Input: Transaction Intake
- Processing: 8 sequential steps
- Output: Operations Handoff
