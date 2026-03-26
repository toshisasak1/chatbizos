# Contributing to ChatBizOS

Thank you for contributing to ChatBizOS.

## How to Contribute

1. Fork the repository.
2. Create a feature branch from `main`.
3. Make focused changes.
4. Open a pull request with a clear summary, rationale, and test notes.

## Pull Request Guidelines

- Keep pull requests scoped to one logical change.
- Link related issues when applicable.
- Explain any user-facing behavior changes.
- Include before/after examples for documentation-heavy changes.

## Code Style

- Agent definitions belong in markdown-based `SOUL.md` files.
- Setup and validation automation should use shell scripts where practical.
- Keep documentation in plain English and optimized for non-engineer readers.
- Prefer explicit configuration and comments over hidden magic.

## Issues and Templates

When opening issues or pull requests, use the repository templates if available. If a template does not exist yet, include:
- problem statement,
- expected behavior,
- actual behavior,
- reproduction steps,
- environment notes.

## Agent Customization Guidelines

- Keep the role of each agent distinct.
- Document why a customization is needed.
- Avoid embedding secrets or environment-specific values in `SOUL.md` files.
- Preserve escalation behavior for compliance-sensitive work.
- When adding a domain-specific variant, include the business assumptions it was designed for.

## Documentation Contributions

Improvements to setup guides, examples, troubleshooting notes, and architecture documentation are especially useful.

## Review Expectations

Maintainers may ask for:
- narrower scope,
- clearer examples,
- stronger defaults for non-engineers,
- safer wording around compliance and automation.
