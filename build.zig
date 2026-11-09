const std = @import("std");
const Translator = @import("translate_c").Translator;

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const tf_path = b.option([]const u8, "tf-path", "path to libtensorflow");

    const gpu_opt = b.option(bool, "gpu", "include GPU deps") orelse true;
    _ = gpu_opt;
    const translate_c = b.dependency("translate_c", .{});

    var c_api_h: std.Build.LazyPath = undefined;
    var tf_include: std.Build.LazyPath = undefined;
    var tf_lib: std.Build.LazyPath = undefined;

    if (tf_path) |tfp| {
        c_api_h = try b.graph.cwdRelativePath(tfp).join(b.graph.arena, "include/tensorflow/c/c_api.h");
        tf_include = try b.graph.cwdRelativePath(tfp).join(b.graph.arena, "include");
        tf_lib = try b.graph.cwdRelativePath(tfp).join(b.graph.arena, "lib");
    } else {
        // we get all the things that we need  form the deps
        const tf_dep = b.lazyDependency("libtensorflow", .{}) orelse {
            @panic("tensorflow lib not found");
        };
        tf_include = tf_dep.path("include/");
        c_api_h = tf_dep.path("include/tensorflow/c/c_api.h");
        tf_lib = tf_dep.path("lib");
    }

    const lib_tf_tc: Translator = .init(translate_c, .{
        .c_source_file = c_api_h,
        .target = target,
        .optimize = optimize,
        .func_bodies = true,
    });

    lib_tf_tc.addIncludePath(tf_include);

    const tensorflow_mod = b.addModule("tensorflow", .{
        .root_source_file = lib_tf_tc.output_file,
        .optimize = optimize,
        .target = target,
        .link_libc = true,
    });

    tensorflow_mod.addLibraryPath(tf_lib);
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
