# Perforce rules

## Setup

* Decide on the name of your package, eg. `github.com/joe/project`
* Add the following to your WORKSPACE file:

    ```bzl
    git_repository(
        name = "com_dsfishlabs_rules_perforce",
        remote = "https://github.com/DeepSilverFishlabs/rules_perforce.git",
    )
    load("@com_dsfishlabs_rules_perforce//perforce:def.bzl", "perforce_repository")

    go_repositories()
    ```
