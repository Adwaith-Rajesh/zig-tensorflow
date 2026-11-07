// https://www.tensorflow.org/install/lang_c#example_program

const std = @import("std");
const tf = @import("tensorflow");

pub fn main() void {
    std.debug.print("{s}\n", .{tf.TF_Version()});
}
