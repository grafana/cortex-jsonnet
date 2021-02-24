# Releases

## How to cut an individual release

### Versioning strategy

Releases of `cortex-jsonnet` are versioned to match the compatible version of Cortex. The release of `cortex-jsonnet` tagged `1.6.0` should match compatible with the release of Cortex tagged  `1.6.0`.
A release of `cortex-jsonnet` should follow shortly after a release of Cortex.

### Publish a release

1. Create a branch for the new release.
2. Update the `CHANGELOG.md`.
   - Add a new section for the new release so that "## master / unreleased" is blank and at the top.
   - The new release section should say "## x.y.0 / YYYY-MM-DD".
   - Ensure changelog entries for the new release are in this order:
     * `[CHANGE]`
     * `[FEATURE]`
     * `[ENHANCEMENT]`
     * `[BUGFIX]`
3. Update `cortex/images.libsonnet` to the released Cortex version.
4. Open a Pull Request for the your branch.
5. Once your Pull Request has been merged, checkout the merge commit and tag a release. Refer to [How to tag a release](#how-to-tag-a-release).
6. Build the `cortex-mixin.zip` for the release.

    ```console
   $ make build-mixin
   ```
7. Add the `cortex-mixin/cortex-mixin.zip` and release change log to the GitHub release.
   - Edit the release in GitHub by going to https://github.com/grafana/cortex-jsonnet/releases/edit/x.y.z

### How to tag a release

> **Note:** Unlike Cortex, release tags are not prefixed with a `v`.

You can do the tagging on the commandline:

```console
$ tag="x.y.z"
$ git tag -s "${tag}" -m "${tag}"
$ git push origin "${tag}"
```
