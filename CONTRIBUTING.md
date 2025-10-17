# Contributing to JIRA Copilot Assistant

Thank you for your interest in contributing! 🎉

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/jira-copilot-assistant.git`
3. Create a branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test your changes thoroughly
6. Commit: `git commit -m "feat: your feature description"`
7. Push: `git push origin feature/your-feature-name`
8. Open a Pull Request

## Development Guidelines

### Bash Scripts

- Use `set -euo pipefail` for main scripts (but NOT in library files)
- Add proper error handling with informative messages
- Include `--help` flag with usage examples
- Test on both macOS and Linux when possible
- Use meaningful variable names (lowercase for local, UPPERCASE for globals)
- Add comments for complex logic

### Python (MCP Server)

- Follow PEP 8 style guidelines
- Use Python 3.13+ features
- Add type hints for function parameters and returns
- Include docstrings for functions and classes
- Test with `test_mcp_client.py` before submitting

### Documentation

- Update README.md for new features
- Add examples to relevant docs/ files
- Keep .env.example synchronized with required variables
- Use clear, concise language
- Include code examples where helpful

## Code Style

### Bash

```bash
# Use 2-space indentation
function example_function() {
  local param="$1"
  
  if [[ -z "$param" ]]; then
    error "Parameter required"
    return 1
  fi
  
  info "Processing: $param"
}
```

### Python

```python
# Use 4-space indentation, type hints, docstrings
def example_function(param: str) -> bool:
    """
    Brief description of function.
    
    Args:
        param: Description of parameter
        
    Returns:
        True if successful, False otherwise
    """
    if not param:
        return False
    
    return True
```

## Testing

### Before Submitting

- [ ] Test all modified scripts end-to-end
- [ ] Verify MCP integration still works (if applicable)
- [ ] Check for hardcoded credentials or sensitive data
- [ ] Run existing test scripts in `mcp-server/`
- [ ] Test with different JIRA ticket types (Story, Bug, Spike, Tech Debt)

### Test Commands

```bash
# Test bash scripts
chmod +x scripts/*.sh
./scripts/jira-groom.sh --help

# Test MCP server
cd mcp-server
source venv/bin/activate
python test_mcp_client.py
```

## Commit Message Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation updates
- `refactor:` - Code refactoring (no functional changes)
- `test:` - Test additions or updates
- `chore:` - Maintenance tasks

**Examples:**
```
feat: add support for custom JIRA fields
fix: resolve story point estimation crash on spike tickets
docs: update MCP setup instructions for VS Code
refactor: extract duplicate code into reusable function
```

## Pull Request Guidelines

### Before Opening a PR

1. **Sync with main branch**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Write a clear description**
   - What problem does this solve?
   - What changes were made?
   - Any breaking changes?
   - Screenshots (if UI/output changes)

3. **Link related issues**
   - Use "Fixes #123" or "Closes #456"

### PR Checklist

- [ ] Code follows style guidelines
- [ ] All tests pass
- [ ] Documentation updated
- [ ] No sensitive data in commits
- [ ] Commit messages follow convention
- [ ] PR description is clear and complete

## Security

### Sensitive Data

**Never commit:**
- API tokens or passwords
- `.env` files with real credentials
- Personal or company-specific URLs (use examples)
- Internal ticket numbers or data

**Always:**
- Use `.env.example` with placeholder values
- Check `git diff` before committing
- Review files in `.gitignore`

### Reporting Security Issues

For security vulnerabilities, please email directly instead of opening a public issue.

## Getting Help

- **Questions?** Open a [Discussion](../../discussions)
- **Bug reports?** Open an [Issue](../../issues)
- **Feature ideas?** Open an [Issue](../../issues) with `enhancement` label

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on the code, not the person
- Help newcomers feel welcome

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

### Approval workflow

- Branches: create feature branches from `main`.
- PRs: open a pull request targeting `main` and add reviewers.
- Approval: At least one approval from the CODEOWNER (`@andymo-sportsbet`) is required before merge.
- CI: Ensure all CI checks pass (if configured).

If you need a merge, request a review from `@andymo-sportsbet` and mention the purpose and testing done.

---

Thank you for making JIRA Copilot Assistant better! 🚀
