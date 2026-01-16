```
```
"if applied, this commit will [YOUR MESSAGE HERE]."
```
```


```
```
# Git Commit Message Convention

We follow the **[Conventional Commits](https://www.conventionalcommits.org/)** specification.

## 🟢 The "Big Three" (Logic & Features)
_These tags directly affect the end-user or the application logic._

* **`feat`**: A new feature for the user (not a new feature for the build script).
  * *Example:* `feat(auth): add google oauth login`
* **`fix`**: A bug fix for the user.
  * *Example:* `fix(search): handle empty string input correctly`
* **`refactor`**: A code change that neither fixes a bug nor adds a feature.
  * *Example:* `refactor(core): simplify user authentication logic`

## 🟡 Maintenance & Optimization
_Changes that improve code quality or developer experience but don't change what the user sees._

* **`chore`**: Maintenance tasks that don't modify src or test files (e.g., updating dependencies, modifying .gitignore).
  * *Example:* `chore(deps): upgrade react to v18`
* **`docs`**: Documentation only changes.
  * *Example:* `docs(readme): add setup instructions for windows`
* **`style`**: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc). *Note: This is not for CSS/UI styling; it's for code style.*
  * *Example:* `style(utils): fix indentation and remove trailing spaces`
* **`test`**: Adding missing tests or correcting existing tests.
  * *Example:* `test(api): add unit tests for user controller`
* **`perf`**: A code change that improves performance.
  * *Example:* `perf(images): implement lazy loading for gallery`

## 🟠 DevOps & Build System
_Specific to the tools that build, deploy, and test the code._

* **`build`**: Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm).
  * *Example:* `build(webpack): reduce bundle size limit`
* **`ci`**: Changes to CI configuration files and scripts (example scopes: GitHub Actions, Travis, Circle).
  * *Example:* `ci(github): add linting step to actions workflow`
* **`revert`**: Reverts a previous commit.
  * *Example:* `revert: feat(auth): add google oauth login`

## 🔴 Special Flags

* **`BREAKING CHANGE`**: Appended to the footer or indicated by a `!` after the type. Used if a change breaks backward compatibility.
  * *Example:* `feat(api)!: remove v1 search endpoint`
