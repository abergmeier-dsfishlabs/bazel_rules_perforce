# Perforce Rules for Bazel (αlpha)

## Setup

* Decide on the name of your package, eg. `github.com/joe/project`
* Add the following to your WORKSPACE file:

    ```bzl
    git_repository(
        name = "com_dsfishlabs_rules_perforce",
        remote = "https://github.com/DeepSilverFishlabs/rules_perforce.git",
    )
    load("@com_dsfishlabs_rules_perforce//perforce:def.bzl", "p4_repository")

    p4_repository(
        name = "content",
    )
    ```

<a name="p4_repository"></a>
## p4\_repository

```bzl
p4_repository(name, stream, revision)
```

Syncs the perforce revision, expecting it contains `BUILD`
files.

<table class="table table-condensed table-bordered table-params">
  <colgroup>
    <col class="col-param" />
    <col class="param-description" />
  </colgroup>
  <thead>
    <tr>
      <th colspan="2">Attributes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>name</code></td>
      <td>
        <code>String, required</code>
        <p>A unique name for this external dependency.</p>
      </td>
    </tr>
  </tbody>
</table>


<a name="new_p4_repository"></a>
## new\_p4\_repository

```bzl
new_p4_repository(name, stream, revision, build_file)
```

Sync a remote repository of a Go project and automatically generates
`BUILD` files in it.  It is an analogy to `new_git_repository` but it recognizes
importpath redirection of Go.

<table class="table table-condensed table-bordered table-params">
  <colgroup>
    <col class="col-param" />
    <col class="param-description" />
  </colgroup>
  <thead>
    <tr>
      <th colspan="2">Attributes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>name</code></td>
      <td>
        <code>String, required</code>
        <p>A unique name for this external dependency.</p>
      </td>
    </tr>
  </tbody>
</table>
