const Window = @This();

const std = @import("std");
const xcb = @import("bindings.zig");
const Core = @import("Core.zig");
const types = @import("../types.zig");

core: *Core,
window: u32 = undefined,

pub fn init(core: *Core, info: types.WindowInfo) Window {
    var self: Window = undefined;
    self.core = core;
    self.window = xcb.generateId(core.connection);
    _ = xcb.createWindow(
        core.connection,
        0,
        self.window,
        core.screen.root,
        0,
        0,
        info.width,
        info.height,
        0,
        xcb.WindowClass.InputOutput,
        core.screen.root_visual,
        0,
        null,
    );
    
    var value = @enumToInt(xcb.EventMask.KeyPress);
    value |= @enumToInt(xcb.EventMask.KeyRelease);
    value |= @enumToInt(xcb.EventMask.ButtonPress);
    value |= @enumToInt(xcb.EventMask.ButtonRelease);
    value |= @enumToInt(xcb.EventMask.PointerMotion);
    
    _ = xcb.changeWindowAttributes(
        core.connection,
        self.window,
        @enumToInt(xcb.Cw.EventMask),
        &[_]u32{ value },
    );

    _ = xcb.mapWindow(core.connection, self.window);

    if (info.title) |t| self.setTitle(t);

    return self;
}

pub fn deinit(window: *Window) void {
    xcb.destroyWindow(window.core.connection, window.window);
}

pub fn setTitle(window: *Window, title: []const u8) void {
    _ = xcb.changeProperty(
        window.core.connection,
        .Replace,
        window.window,
        @enumToInt(xcb.Defines.Atom.WmName),
        @enumToInt(xcb.Defines.Atom.String),
        @bitSizeOf(u8),
        @intCast(u32, title.len),
        @ptrCast(*const c_void, title),
    );
}
