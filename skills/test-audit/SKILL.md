---
name: test-audit
description: "Audit test coverage gaps and implement missing tests for React + Vite + Testing Library projects. Use when: 'audit tests', 'evaluate test coverage', 'add missing tests', 'improve test suite', 'test gap analysis', 'increase coverage', 'write tests for untested files', 'test evaluation', 'test inventory', 'check what needs tests', 'coverage report', 'test strategy review', 'test pyramid evaluation'. Triggers on any request to evaluate, plan, or implement test coverage improvements across a codebase."
---

# Test Audit and Implementation

Systematic workflow for auditing test coverage, planning improvements against the test pyramid, implementing tests following established project patterns, and verifying the full suite passes.

**Core principle:** Audit first, plan second, implement third, verify last. Never write tests without understanding what exists.

## When to Use

- Evaluating test coverage for a project or feature area
- Identifying untested files or missing test scenarios
- Implementing a batch of tests across multiple layers
- Setting or raising coverage thresholds
- Onboarding to a codebase's test patterns before contributing

## When NOT to Use

- Single unit test for a single new function (just write it)
- TDD for a new feature (use TDD skill instead)
- Debugging a failing test (use systematic debugging)

---

## Phase 1: Audit

### Step 1 — Inventory Source and Test Files

```bash
# Source files (excluding tests, types, config)
find src -type f \( -name "*.tsx" -o -name "*.ts" \) \
  ! -name "*.test.*" ! -name "*.spec.*" ! -name "*.d.ts" \
  ! -path "*/test/*" ! -path "*/test-utils/*" | sort

# Test files
find src -type f \( -name "*.test.*" -o -name "*.spec.*" \) | sort
find tests -type f -name "*.spec.*" 2>/dev/null | sort
```

### Step 2 — Build Gap Matrix

For every source file, determine:
1. Does a colocated test file exist?
2. What layer does it belong to? (service / hook / component / page / util / e2e)
3. Approximate complexity (LOC, number of exports)
4. If tested, are critical paths covered? (happy path, error, edge cases)

Output a table:

| File | Layer | Test? | Est. LOC | Missing Scenarios |
|------|-------|-------|----------|-------------------|
| src/services/foo.ts | service | YES | 120 | error paths, dual-mode |
| src/hooks/useBar.ts | hook | NO | 180 | all |
| src/pages/Baz.tsx | page | YES | 200 | empty state, search |

### Step 3 — Evaluate Against the Test Pyramid

```
         /  E2E  \        ← Few: critical user journeys only
        /----------\
       /  Page Tests \    ← Pages with mocked hooks
      /--------------\
     / Component Tests \  ← UI units with mocked deps
    /------------------\
   /   Hook + Service    \ ← State logic + DB layer
  /________________________\
 /     Utils (pure fns)      \ ← Highest count, fastest
```

Flag pyramid violations:
- More E2E than unit tests → inverted pyramid
- Hooks without tests → blind spot in complex async logic
- Services without dual-mode tests → DB failures undetected
- Zero E2E → no confidence in real browser behavior

### Step 4 — Count and Summarize

Run `npm test` and count total tests. Report:
- Total test files, total test count
- Coverage by layer (services: X/Y tested, hooks: X/Y, etc.)
- Top 5 largest untested files by LOC
- Test-to-source ratio per layer

---

## Phase 2: Plan

### Prioritization Order

1. **Untested services** — data corruption risk, highest ROI
2. **Untested hooks** — complex state, async, optimistic updates
3. **Untested pages** — integration of hooks into UI
4. **Untested shared components** — used across many pages
5. **Missing component scenarios** — callbacks, error states
6. **E2E gaps** — only for critical multi-page journeys
7. **Coverage thresholds** — raise after filling gaps

### Plan Template

For each phase, list files with estimated test counts and reference templates:

```
Phase 1: [Layer] (est. N tests)
- fooService.test.ts — dual-mode, CRUD, error paths (template: existing barService.test.ts)
- ...
```

**Always identify template files** — find existing tests in the project that follow the pattern you'll replicate. Never invent patterns when the project has established ones.

**Present the plan to the user and get approval before implementing.**

---

## Phase 3: Implementation

### Before Writing Any Test

1. Read the source file being tested
2. Read the template test file (existing test with same pattern)
3. Identify: imports, mocking strategy, factory functions, assertion patterns
4. Replicate the pattern — do not invent new patterns

### Pattern: Service Tests

```typescript
// Dual-mode: DB disabled (returns early) + DB enabled (queries Supabase)
describe('fooService', () => {
  describe('DB disabled', () => {
    beforeEach(() => {
      vi.resetModules();
      vi.stubEnv('VITE_SUPABASE_URL', '');
      vi.doMock('@/lib/supabase', () => ({ supabase: { from: vi.fn() } }));
    });
    afterEach(() => vi.unstubAllEnvs());
    // loadX returns [], insertX returns null, etc.
  });

  describe('DB enabled', () => {
    beforeEach(async () => {
      vi.resetModules();
      vi.stubEnv('VITE_SUPABASE_URL', 'https://test.supabase.co');
      // Chainable builder mock for Supabase queries
      mockFrom = vi.fn().mockReturnValue(createBuilder());
      vi.doMock('@/lib/supabase', () => ({ supabase: { from: mockFrom } }));
    });
    // Test: correct table, data transforms, error handling
  });
});
```

### Pattern: Hook Tests

```typescript
vi.mock('@/services/fooService', () => ({
  loadFoo: vi.fn(), insertFoo: vi.fn(), deleteFoo: vi.fn(), updateFoo: vi.fn(),
}));

describe('useFoo', () => {
  // Setup helper that renders hook and waits for initial load
  async function setup(session = mockSession) {
    const { result } = renderHook(() => useFoo(session, false));
    await waitFor(() => expect(result.current.isInitialLoad).toBe(false));
    return result;
  }

  it('loads on mount', async () => { /* waitFor + assert */ });
  it('returns empty when no session', async () => { /* session=null */ });
  it('adds optimistically and reverts on error', async () => { /* act + assert */ });
  it('prevents duplicate concurrent adds', async () => { /* race condition */ });
  it('clamps values within range', () => { /* min/max boundary */ });
  it('sets isLoadError on DB failure', async () => { /* mockRejectedValue */ });
});
```

### Pattern: Page Tests

```typescript
vi.mock('@/hooks/useFoo', () => ({ useFoo: vi.fn() }));
import { useFoo } from '@/hooks/useFoo';

const defaultHook = {
  items: [], isInitialLoad: false, isLoadError: false,
  retryLoad: vi.fn(), addItem: vi.fn(), getFiltered: vi.fn().mockReturnValue([]),
};

describe('FooPage', () => {
  beforeEach(() => { vi.mocked(useFoo).mockReturnValue(defaultHook); });

  // Auth states: authenticating, no session (AuthGate), session
  // Data states: loading, error+retry, empty, populated
  // Interactions: search input, sort toggle, add modal open/close, tab switch
});
```

### Pattern: Component Tests

```typescript
function makeItem(overrides = {}) { return { id: '1', name: 'Test', ...overrides }; }
const defaultProps = { onRemove: vi.fn(), onUpdate: vi.fn(), onToggle: vi.fn() };

describe('FooCard', () => {
  // Render: name, badges, level display
  // Callbacks: verify correct args on click
  // States: active class, edit toggle
  // Fallbacks: image error handler
});
```

### Pattern: E2E Tests (Playwright)

```typescript
import { test, expect } from '@playwright/test';

test.describe('Feature', () => {
  test('page loads with expected elements', async ({ page }) => {
    await page.goto('/path');
    await expect(page.locator('h1')).toContainText('Title');
    await expect(page.locator('.element')).toBeVisible();
  });
});
```

### After Writing Each Test File

```bash
npm test -- --run path/to/new.test.tsx
```

Fix failures immediately. Do not batch — test each file as you write it.

---

## Phase 4: Verification

Run in order. Stop and fix at each failure:

```bash
npm test                    # Full unit/component/hook test suite
npm run lint                # ESLint
npm run format:check        # Prettier (run `npm run format` to auto-fix)
npm run test:coverage       # Coverage report
```

### Coverage Thresholds

After all gaps filled, set thresholds ~5 points below measured values:

```typescript
// vite.config.ts → test.coverage.thresholds
thresholds: {
  lines: <measured - 5>,
  statements: <measured - 5>,
  functions: <measured - 5>,
  branches: <measured - 5>,
}
```

Never lower existing thresholds. Only raise them.

---

## Quick Reference

| Layer | File Location | Mock Strategy | Key Tests |
|-------|--------------|---------------|-----------|
| Service | `src/services/**` | `vi.stubEnv` + `vi.doMock` + dynamic import | Dual-mode, CRUD, error throw, data transform |
| Hook | `src/hooks/**` | `vi.mock` service layer | Load, CRUD, optimistic rollback, race guard, filter/sort |
| Page | `src/pages/**` | `vi.mock` hooks | Auth states, load/error/empty/data, search, modal, tabs |
| Component | `src/pages/**/components/**` | Props only | Render, callbacks with args, CSS classes, image fallback |
| Util | `src/utils/**` | None | Pure input/output, edge cases, boundary values |
| E2E | `tests/*.spec.ts` | None (real browser) | Navigation, visibility, attributes |

## Anti-Patterns

| Anti-Pattern | Do This Instead |
|-------------|-----------------|
| Snapshot tests for logic | Explicit assertions on specific values |
| `any` casts in test data | Proper typed fixtures matching real interfaces |
| Inline object literals everywhere | Factory functions: `makeItem(overrides)` |
| Testing implementation details | Test behavior: inputs in, outputs out |
| Mocking what you own | Only mock external boundaries (DB, network) |
| No error path tests | Always test: what happens when X throws? |
| E2E for unit logic | Push down to smallest testable layer |
| Shared mutable state between tests | `beforeEach` reset, isolated fixtures |
| Writing tests without reading existing patterns | Find template test, replicate structure |

## Checklist Before Done

- [ ] All new tests pass individually (`npm test -- --run path`)
- [ ] Full test suite green (`npm test`)
- [ ] Lint clean (`npm run lint`)
- [ ] Format clean (`npm run format:check`)
- [ ] Coverage did not decrease
- [ ] No `any` casts or `@ts-ignore` in test files
- [ ] Each test file has a factory function, not inline literals
- [ ] Error paths tested, not just happy paths
