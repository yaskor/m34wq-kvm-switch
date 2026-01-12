const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    // const optimize = b.standardOptimizeOption(.{});
    const optimize = .ReleaseSmall;

    const hidapi = b.dependency("hidapi", .{});

    const exe = b.addExecutable(.{
        .name = "KVM-Switch",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    exe.subsystem = .Windows;
    exe.root_module.addCSourceFile(.{
        .file = b.path("resource.rc"),
        .flags = &.{},
    });
    exe.root_module.addIncludePath(hidapi.path("hidapi"));
    exe.root_module.addCSourceFile(.{
        .file = hidapi.path("windows/hid.c"),
        .flags = &.{},
    });
    exe.root_module.linkSystemLibrary("setupapi", .{});

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    if (b.args) |args| run_cmd.addArgs(args);
    b.step("run", "Run").dependOn(&run_cmd.step);
}
