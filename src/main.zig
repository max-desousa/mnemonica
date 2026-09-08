const std = @import("std");
const config = @import("config");
const messaging = @import("messaging");

pub fn main(init: std.process.Init) !void {
    const arena: std.mem.Allocator = init.arena.allocator();

    // Accessing command line arguments:
    const args = try init.minimal.args.toSlice(arena);

    const io = init.io;

    const cfg : config = config.ParseFromArgs(args) catch |err| {
        if (error.HelpMessageRequested == err) {
            messaging.PrintHelp(io);
        }
        return;
    };

    _ = &cfg;

    //// Stdout is for the actual output of your application, for example if you
    //// are implementing gzip, then only the compressed bytes should be sent to
    //// stdout, not any debugging messages.
    //var stdout_buffer: [1024]u8 = undefined;
    //var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    //const stdout_writer = &stdout_file_writer.interface;

    //try mnemonica.printAnotherMessage(stdout_writer);

    //try stdout_writer.flush(); // Don't forget to flush!
}
