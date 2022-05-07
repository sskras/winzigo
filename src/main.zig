const Core = @This();
const builtin = @import("builtin");
const enums = @import("enums.zig");

pub const Button = enums.Button;
pub const Key = enums.Key;

pub const Pos = struct {
    x: i16,
    y: i16,
};

pub const Dim = struct {
    width: u16,
    height: u16,
};

pub const Event = struct {
    window: Window,
    ev: union(enum) {
        key_press: struct {
            key: Key,
        },
        key_release: struct {
            key: Key,
        },
        button_press: struct {
            button: Button,
        },
        button_release: struct {
            button: Button,
        },
        mouse_scroll: struct {
            scroll_x: i2,
            scroll_y: i2,
        },
        mouse_motion: Pos,
        mouse_enter: Pos,
        mouse_leave: Pos,
        focus_in: void,
        focus_out: void,
        window_resize: Dim,
        quit: void,
    },
};

pub const WindowInfo = struct {
    title: ?[]const u8 = null,
    width: u16 = 256,
    height: u16 = 256,
};

fn CoreType() type {
    if (builtin.cpu.arch == .wasm32) return @import("wasm/Core.zig");
    return @import("xcb/Core.zig");
}

fn WindowType() type {
    return CoreType().Window;
}

internal: CoreType(),

pub fn init() !Core {
    return Core{ .internal = try CoreType().init() };
}

pub fn deinit(core: *Core) void {
    core.internal.deinit();
}

pub fn createWindow(core: *Core, info: WindowInfo) Window {
    return .{ .internal = core.internal.createWindow(info) };
}

pub fn pollEvent(core: *Core) ?Event {
    return core.internal.pollEvent();
}

pub fn waitEvent(core: *Core) ?Event {
    return core.internal.waitEvent();
}

pub fn getKeyDown(core: *Core, key: Key) bool {
    return core.internal.getKeyDown(key);
}

pub const Window = struct {
    internal: WindowType(),

    pub fn init(info: WindowInfo) Window {
        return .{ .internal = WindowType().init(info) };
    }

    pub fn initFromInternal(internal: WindowType()) Window {
        return .{ .internal = internal };
    }

    pub fn deinit(window: *Window) void {
        window.internal.deinit();
    }

    pub fn setTitle(window: *Window, title: []const u8) void {
        window.internal.setTitle(title);
    }

    pub fn setSize(window: *Window, width: u16, height: u16) void {
        window.internal.setSize(width, height);
    }
};
