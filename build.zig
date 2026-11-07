const std = @import("std");
const Translator = @import("translate_c").Translator;

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const translate_c = b.dependency("translate_c", .{});
    const lib_tf_dep = b.dependency("libtensorflow", .{});

    const lib_tf_tc: Translator = .init(translate_c, .{
        .c_source_file = lib_tf_dep.path("include/tensorflow/c/c_api.h"),
        .target = target,
        .optimize = optimize,
        .func_bodies = true,
    });

    lib_tf_tc.addIncludePath(lib_tf_dep.path("include"));

    const tensorflow_mod = b.addModule("tensorflow", .{
        .root_source_file = lib_tf_tc.output_file,
        .optimize = optimize,
        .target = target,
    });

    tensorflow_mod.addLibraryPath(lib_tf_dep.path("lib"));
    tensorflow_mod.linkSystemLibrary("tensorflow", .{});
    // hello exe
    {
        const hello_exe = b.addExecutable(.{
            .name = "hello",
            .root_module = b.createModule(.{
                .root_source_file = b.path("test/hello.zig"),
                .optimize = optimize,
                .target = target,
                .imports = &.{
                    .{ .name = "tensorflow", .module = tensorflow_mod },
                },
            }),
        });
        b.installArtifact(hello_exe);
    }
}
