const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zgps_lib = b.addStaticLibrary(.{
        .name = "zig-gps",
        .root_source_file = b.path("src/gps.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(zgps_lib);

    // Docs
    const zgps_docs = zgps_lib;
    const build_docs = b.addInstallDirectory(.{
        .source_dir = zgps_docs.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "../docs",
    });
    const build_docs_step = b.step("docs", "Build the zig-gps library docs");
    build_docs_step.dependOn(&build_docs.step);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
