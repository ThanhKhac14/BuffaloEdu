# Templates (Self-study) — Design Spec
Date: 2026-04-10
Author: Design Systems Team

## 1. Overview
Ship a teacher-first "Self-study Template" feature that lets teachers create, save, preview and assign reusable practice templates quickly. Focus on rapid authoring and discoverability for the teacher MVP.

## 2. Goals & Success Criteria
- Reduce time-to-create simple template to under 3 minutes.
- First-teacher-to-live within 48 hours of onboarding.
- Teacher NPS ≥ 40 for creation/assignment flows.

## 3. Scope (MVP)
- Create & edit template: title, description, tags, sections, questions (manual/CSV/import).
- Save as template and list templates with search+filters.
- Preview student view (read-only) and Assign to class with access code/link.
- Basic autosave (5s) + explicit Save and optimistic UI.

## 4. Core Flows
- New Template: New → metadata → add sections → add questions → save → optional publish/assign.
- Edit Template: open → edit structure or question → autosave → Save.
- Assign Template: select class(es) → set availability & attempts → generate code/link → notify.
- Preview: toggle Student Preview to view final student UI.

## 5. Pages & UI Notes
- Templates List (teacher dashboard)
  - Actions: New Template, Import, Search, Filters (subject, tags).
  - Empty state: Bo medium-thinking + CTA.
- Template Editor
  - Left: structure tree (drag reorder sections/questions).
  - Center: editor canvas (question editor with options and explanation field).
  - Right: properties (duration, attempts, visibility, tags, preview toggle).
  - Autosave every 5s; top-right primary Save button.
- Assign Modal
  - Pick class, schedule, attempts, generate access code/link, send quick-notify.

## 6. Components (priority)
- Atoms: `PrimaryButton`, `InputField`, `StatusBadge` (use LOCKED tokens per `02-design.md`).
- Molecules: `TemplateCard` (list item), `QuestionEditor` (stem + options + explanation), `AssignModal`.
- Organisms: `TemplateEditorShell` (structure tree + editor + panel).

Each component must:
- Accept `className?: string`.
- Use typed props (no `any`).
- Use Tailwind utility classes with `var()` CSS tokens for colors.

## 7. Data Model (concise)
- Template { id, title, description, tags[], sections[] , settings, authorId, createdAt, updatedAt }
- Section { id, title, questions[] }
- Question { id, stem, type, options[], answer, explanation?, metadata }
- Assignment { id, templateId, classId, accessCode, startsAt?, endsAt?, attemptsAllowed }

## 8. Accessibility
- Labels associated with inputs (`htmlFor`).
- Error messages in `aria-live` regions.
- Color contrast using locked tokens; never rely on color alone.
- Keyboard navigation: tab order, arrow nav for options, Esc to close modals.
- 44×44px minimum interactive targets.

## 9. Error Handling & Sync
- Autosave failure: show toast + retry; allow manual Save.
- Publish/Assign failure: block action, show actionable error.
- Concurrent edits: last-writer-wins with conflict toast offering revert or duplicate.

## 10. Visual Direction & Assets
- Tone: warm rural Vietnam — linen textures, woven accents, subtle nón lá motif, friendly Bo in empty states.
- Fonts: Be Vietnam Pro (UI), JetBrains Mono (mono/code). Dark mode via root `dark` class.
- Tokens: obey `02-design.md` LOCKED tokens; added accent tokens only (woven/nonla/tealstitch).

## 11. Metrics & QA
- Events: `template.created`, `template.saved`, `template.published`, `assignment.created`, `preview.opened`.
- Tests: unit tests for editor logic, E2E for create→assign→preview flows, automated accessibility checks.

## 12. Deliverables
- Spec file (this document).
- Tokens: `design/tokens.css` (imported separately) and `design/tokens.json` mapping.
- TSX snippets for core components (PrimaryButton, InputField, StatusBadge, QuestionEditor, AssignModal) provided to frontend team for Stitch import.

## 13. Next Steps
1. Review and approve this spec.
2. On approval: create implementation plan (writing-plans skill) and wire up API contracts.
3. Start UI work: Templates List → Template Editor → Assign flow.

---
Spec written to: `/docs/superpowers/specs/2026-04-10-templates-design.md`
