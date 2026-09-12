const std = @import("std");

pub fn PrintHelp(writer : *std.Io.Writer) !void {
    try writer.print("This is the help message\n", .{});
}
