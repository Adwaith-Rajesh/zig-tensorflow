const std = @import("std");
const tf = @import("tensorflow");

extern "c" fn dlopen(filename: [*:0]const u8, flags: c_int) ?*anyopaque;
extern "c" fn dlclose(handle: *anyopaque) c_int;
extern "c" fn dlerror() ?[*:0]const u8;
const RTLD_LAZY: c_int = 1; // value on Linux/glibc

const sonames = [_][:0]const u8{
    "libcuda.so.1",
    "libcudart.so.12",
    "libcublas.so.12",
    "libcublasLt.so.12",
    "libcudnn.so.9",
    "libcufft.so.11",
    "libcurand.so.10",
    "libcusolver.so.11",
    "libcusparse.so.12",
    "libnvrtc.so.12",
    "libnvJitLink.so.12",
    "libcudnn_cnn.so.9",
    "libcublasLt.so.12",
    "libcudnn.so.9",
};

pub fn main() !void {
    std.debug.print("TF C library version: {s}\n\n", .{std.mem.span(tf.TF_Version())});

    // 1. Ask TensorFlow which devices it registered.
    const status = tf.TF_NewStatus();
    defer tf.TF_DeleteStatus(status);
    const graph = tf.TF_NewGraph();
    defer tf.TF_DeleteGraph(graph);
    const opts = tf.TF_NewSessionOptions();
    defer tf.TF_DeleteSessionOptions(opts);

    const sess = tf.TF_NewSession(graph, opts, status);
    if (tf.TF_GetCode(status) != tf.TF_OK) {
        std.debug.print("session failed: {s}\n", .{std.mem.span(tf.TF_Message(status))});
        return error.SessionFailed;
    }
    defer {
        tf.TF_CloseSession(sess, status);
        tf.TF_DeleteSession(sess, status);
    }

    const devs = tf.TF_SessionListDevices(sess, status);
    defer tf.TF_DeleteDeviceList(devs);

    var have_gpu = false;
    var i: c_int = 0;
    while (i < tf.TF_DeviceListCount(devs)) : (i += 1) {
        const name = std.mem.span(tf.TF_DeviceListName(devs, i, status));
        const kind = std.mem.span(tf.TF_DeviceListType(devs, i, status));
        std.debug.print("device: {s} ({s})\n", .{ name, kind });
        if (std.mem.eql(u8, kind, "GPU")) have_gpu = true;
    }
    std.debug.print("GPU registered: {}\n\n", .{have_gpu});

    // 3. Can this executable resolve each library on its own?
    std.debug.print("\n-- dlopen probe from the executable --\n", .{});
    for (sonames) |s| {
        if (dlopen(s.ptr, RTLD_LAZY)) |h| {
            _ = dlclose(h);
            std.debug.print("  ok       {s}\n", .{s});
        } else {
            const err = if (dlerror()) |e| std.mem.span(e) else "unknown error";
            std.debug.print("  MISSING  {s}: {s}\n", .{ s, err });
        }
    }
}
