#include <stdio.h>
#include <git2.h>

void checkError(int error) {
    if (error >= 0) {
      return;
    }

    const git_error *e = git_error_last();

    printf("Git Error %i: %i -> %s\n", error, e->klass, e->message);

    exit(1);
}

int main(int argc, char **argv) {
    printf("C reference\n");

    git_libgit2_init();

    git_repository *repo = NULL;
    checkError(git_repository_open_ext(&repo, "./", 0, NULL));

    git_reference *ref = NULL;
    checkError(git_repository_head(&ref, repo));

    char oid_hex[GIT_OID_HEXSZ+1] = GIT_OID_HEX_ZERO;
    const char *refname;

    switch (git_reference_type(ref)) {
      case GIT_REFERENCE_DIRECT:
        git_oid_fmt(oid_hex, git_reference_target(ref));
        printf("Direct - OID Hex: [%s]\n", oid_hex);
        break;

      case GIT_REFERENCE_SYMBOLIC:
        printf("Symbolic - Target Name: %s\n", git_reference_symbolic_target(ref));
        break;

      default:
        fprintf(stderr, "Unexpected reference type\n");
        exit(1);
    }

    const char *branchname;
    checkError(git_branch_name(&branchname, ref));

    printf("Branch name: %s\n", branchname);

    /*git_strarray remotes = {0};*/
    /*int listerror = git_remote_list(&remotes, repo);*/

    /*printf("git remotes %i\n", (int)remotes.count);*/

    git_reference_free(ref);
    git_repository_free(repo);
    git_libgit2_shutdown();

    return 0;
}
