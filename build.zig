const std = @import("std");
const sources = @import("sources.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // clone
    const git_step = b.addSystemCommand(&.{
        "git",
        "clone",
        "https://github.com/facebook/yoga.git",
        "--depth=1",
    });

    // build yoga
    const yoga_lib = b.addStaticLibrary(.{
        .name = "yoga",
        .target = target,
        .optimize = optimize,
    });
    yoga_lib.linkLibCpp();
    yoga_lib.addIncludePath(b.path("yoga"));
    for (sources.yoga_cpps) |cpp| {
        yoga_lib.addCSourceFile(.{
            .file = b.path(cpp),
            .flags = &.{"-std=c++20"},
        });
    }

    // yoga test
    const cwd = std.fs.cwd();
    cwd.access("yoga", .{
        .mode = .read_only,
    }) catch |err| {
        if (err == error.FileNotFound) {
            // git clone
            yoga_lib.step.dependOn(&git_step.step);
        }
    };

    b.installArtifact(yoga_lib);

    // translate C files to Zig
    const yoga_zig_step = b.addTranslateC(.{
        .root_source_file = b.path("yoga/yoga/yoga.h"),
        .target = target,
        .optimize = optimize,
    });
    const yoga_zig_mod = b.addModule("yoga_zig", .{
        .root_source_file = yoga_zig_step.getOutput(),
        .target = target,
        .optimize = optimize,
    });
    yoga_zig_mod.link_libcpp = true;
}
