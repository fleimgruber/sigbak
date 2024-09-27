const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const version = std.SemanticVersion{ .major = 0, .minor = 1, .patch = 0 };

    var flags = std.BoundedArray([]const u8, 16){};
    flags.appendSliceAssumeCapacity(&EXE_FLAGS);

    const protocc_run = b.addSystemCommand(&.{"protoc-c"});
    protocc_run.addArgs(&.{"--c_out=."});
    protocc_run.addArgs(&PROTO_SOURCES);

    const sigbak_exe = b.addExecutable(.{
        .name = "sigbak",
        .target = target,
        .version = version,
        .optimize = optimize,
    });
    sigbak_exe.addCSourceFiles(.{
        .files = &EXE_SOURCES,
        .flags = flags.constSlice(),
    });
    sigbak_exe.addCSourceFiles(.{
        .files = &COMPAT_SOURCES,
        .flags = flags.constSlice(),
    });
    sigbak_exe.addCSourceFiles(.{
        .files = &PROTO_GENERATED_SOURCES,
        .flags = flags.constSlice(),
    });
    sigbak_exe.linkSystemLibrary("libcrypto");
    sigbak_exe.linkSystemLibrary("libprotobuf-c");
    sigbak_exe.linkSystemLibrary("sqlite3");
    sigbak_exe.linkLibC();

    sigbak_exe.step.dependOn(&protocc_run.step);

    b.installArtifact(sigbak_exe);

    const run_cmd = b.addRunArtifact(sigbak_exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

const EXE_FLAGS = .{
    "-I.",
    "-Icompat",
};

const EXE_SOURCES = .{
    "cmd-check-backup.c",
    "cmd-dump-backup.c",
    "cmd-export-attachments.c",
    "cmd-export-avatars.c",
    "cmd-export-database.c",
    "cmd-export-messages.c",
    "mime.c",
    "sbk-attachment-tree.c",
    "sbk-attachment.c",
    "sbk-database.c",
    "sbk-edit.c",
    "sbk-file.c",
    "sbk-frame.c",
    "sbk-mention.c",
    "sbk-message.c",
    "sbk-open.c",
    "sbk-quote.c",
    "sbk-reaction.c",
    "sbk-read.c",
    "sbk-recipient-tree.c",
    "sbk-recipient.c",
    "sbk-sqlite.c",
    "sbk-thread.c",
    "sigbak.c",
};

const PROTO_SOURCES = .{
    "backup.proto",
    "database.proto",
};

const PROTO_GENERATED_SOURCES = .{
    "backup.pb-c.c",
    "database.pb-c.c",
};

const COMPAT_SOURCES = .{
    "compat/asprintf.c",
    "compat/bs_cbb.c",
    "compat/err.c",
    "compat/explicit_bzero.c",
    "compat/fopen.c",
    "compat/getprogname.c",
    "compat/hkdf.c",
    "compat/hmac_ctx_new.c",
    "compat/pledge.c",
    "compat/readpassphrase.c",
    "compat/reallocarray.c",
    "compat/unveil.c",
};
