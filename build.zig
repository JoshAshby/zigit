const Builder = @import("std").build.Builder;
const builtin = @import("builtin");

pub fn build(b: *Builder) void {
    b.setPreferredReleaseMode(builtin.Mode.Debug);
    const mode = b.standardReleaseOptions();

    // Setup the zig build
    const exe = b.addExecutable("zigit", "src/main.zig");
    exe.setBuildMode(mode);
    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("git2");
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Setup the C reference build
    const cexe = b.addExecutable("cgit", null);
    cexe.setBuildMode(mode);
    cexe.addCSourceFile("src/main.c", &[_][]const u8{"-std=c99"});
    cexe.linkSystemLibrary("c");
    cexe.linkSystemLibrary("git2");
    cexe.install();

    const crun_cmd = cexe.run();
    crun_cmd.step.dependOn(b.getInstallStep());

    const crun_step = b.step("runc", "Run the c app");
    crun_step.dependOn(&crun_cmd.step);
}
