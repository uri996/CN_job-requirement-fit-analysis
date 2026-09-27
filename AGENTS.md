# AGENTS.md

## Project Purpose

This repository contains CN_job-requirement-fit-analysis, a Chinese-language Skill for analyzing mainland China campus recruitment and internship job descriptions and candidate-job fit.

Before modifying SKILL.md:

1. Read `docs/SPECIFICATION.md`.
2. Read `docs/DEVELOPMENT.md`.
3. Read the current `SKILL.md`.
4. If an Evaluation repository is available, read only the files needed for the assigned task.

---

## Core Rules

Do not change the confirmed product scope unless explicitly instructed.

Do not invent candidate facts.

Do not invent JD requirements.

Do not treat missing resume evidence as proof that the candidate lacks a skill.

Do not merge qualification conflicts with capability matching.

Do not automatically treat job location as a hard qualification.

Do not turn suggestions or industry examples into claims about what the JD explicitly requires.

Do not drift into interview preparation.

---

## Privacy

Never copy real candidate data from the private Evaluation repository into this repository.

Never add:

- names;
- phone numbers;
- email addresses;
- student IDs;
- private resumes;
- private test cases;

to the public Skill repository.

---

## Development Rules

Do not modify `main` directly when working on a version iteration.

Use the assigned iteration branch.

Prefer targeted changes over rewriting the entire Skill.

Do not refactor file structure and change major business logic in the same step unless explicitly requested.

Do not claim a test passed unless the test was actually executed.

If fresh-context testing cannot be performed reliably, report that limitation instead of simulating a successful Evaluation.

---

## Testing Rules

Test fixtures are not to be modified merely to make the Skill pass.

If a test appears incorrect or inconsistent with the Specification:

stop and report the conflict.

Actual test outputs and evaluation reports may be written to the private Evaluation repository if the task permits.

---

## Stop Conditions

Stop and request human review if:

- requirements conflict;
- a product decision is needed;
- test expectations conflict with the Specification;
- repeated repair cycles do not improve results;
- a severe regression appears;
- baseline files may be damaged;
- privacy boundaries may be crossed.