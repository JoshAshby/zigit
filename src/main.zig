const std = @import("std");
const warn = std.debug.warn;

const libgit = @cImport({
    @cInclude("git2.h");
});


fn checkError(error_code: var) !void {
    if (error_code >= 0) { return; }

    const git_error = libgit.git_error_last();
    const errorMessage = git_error.*.message[0..std.mem.len(u8, git_error.*.message)];

    warn("Git error {}: {} -> {}\n", .{ error_code, git_error.*.klass, errorMessage });

    switch (@intToEnum(libgit.git_error_code, error_code)) {
        .GIT_OK => {},
        .GIT_ERROR => return error.GitGenericError,
        .GIT_ENOTFOUND => return error.GitNotFound,
        .GIT_EEXISTS => return error.GitExists,
        .GIT_EAMBIGUOUS => return error.GitAmiguous,
        .GIT_EBUFS => return error.GitBufferToShort,
        .GIT_EUSER => return error.GitSpecial,
        .GIT_EBAREREPO => return error.GitBareRepo,
        .GIT_EUNBORNBRANCH => return error.GitUnbornBranch,
        .GIT_EUNMERGED => return error.GitUnMerged,
        .GIT_ENONFASTFORWARD => return error.GitNonFastForward,
        .GIT_EINVALIDSPEC => return error.GitInvalidSpec,
        .GIT_ECONFLICT => return error.GitConflict,
        .GIT_ELOCKED => return error.GitLocked,
        .GIT_EMODIFIED => return error.GitModiffied,
        .GIT_EAUTH => return error.GitAuth,
        .GIT_ECERTIFICATE => return error.GitCertificate,
        .GIT_EAPPLIED => return error.GitApplied,
        .GIT_EPEEL => return error.GitPeel,
        .GIT_EEOF => return error.GitEOF,
        .GIT_EINVALID => return error.GitInvalid,
        .GIT_EUNCOMMITTED => return error.GitUncommitted,
        .GIT_EDIRECTORY => return error.GitDirectory,
        .GIT_EMERGECONFLICT => return error.GitMergeConflic,
        .GIT_PASSTHROUGH => return error.GitPasThrough,
        .GIT_ITEROVER => return error.GitIterOver,
        .GIT_RETRY => return error.GitRetry,
        .GIT_EMISMATCH => return error.GitMismatch,
        .GIT_EINDEXDIRTY => return error.GitIndexDirty,
        .GIT_EAPPLYFAIL => return error.GitApplyFail,
        else => {}
    }
}

pub fn main() !void {
    warn("Zig implementation\n", .{});

    _ = libgit.git_libgit2_init();
    defer _ = libgit.git_libgit2_shutdown();

    //var root: libgit.git_buf = libgit.git_buf{
        //.ptr=null,
        //.asize=0,
        //.size=0
    //};

    //const rootError = libgit.git_repository_discover(&root, "./", 0, null);
    //defer libgit.git_buf_free(&root);

    //if (rootError < 0) {
        //const e = libgit.git_error_last();
        //warn("Git Error {}: {} -> {}\n", .{ rootError, e.*.klass, e.*.message[0..e.*.message.*] });
        //return;
    //}

    //warn("Zig root {s}\n", .{ root.ptr[0..root.size] });

    var repo: ?*libgit.git_repository = undefined;
    try checkError(libgit.git_repository_open_ext(&repo, "./", 0, null));
    defer libgit.git_repository_free(repo);

    var ref: ?*libgit.git_reference = undefined;
    try checkError(libgit.git_repository_head(&ref, repo));
    defer libgit.git_reference_free(ref);

    switch (libgit.git_reference_type(ref)) {
        .GIT_REFERENCE_DIRECT => {
            var oid_hex: [40:0]u8 = libgit.GIT_OID_HEX_ZERO.*;

            libgit.git_oid_fmt(&oid_hex, libgit.git_reference_target(ref));

            warn("Direct - OID Hex: [{}]\n", .{ oid_hex });
        },
        .GIT_REFERENCE_SYMBOLIC => {
            warn("Symbolic - Target Name: {}\n", .{ libgit.git_reference_symbolic_target(ref) });
        },
        else => {}
    }

    var branch_name: [*c]const u8 = undefined;
    try checkError(libgit.git_branch_name(&branch_name, ref));

    const branchName = branch_name[0..std.mem.len(u8, branch_name)];

    warn("Branch name: {}\n", .{ branchName });

}
