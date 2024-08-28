module Colour {

    import IO;

    record RGB {
        var r: real;
        var g: real;
        var b: real;
    }

    proc RGB.print(stream) {
        var ir = (255 * r):uint;
        var ig = (255 * g):uint;
        var ib = (255 * b):uint;
        try {
            stream.writef("%u %u %u\n", ir, ig, ib);
        }
        catch e: Error {
            writeln("Error writing to stream: ", e);
        }
    }

    const BLACK = new RGB(0.0, 0.0, 0.0);
    const LIGHT_BLUE = new RGB(0.5, 0.6, 1.0);
    const RED = new RGB(1.0, 0.0, 0.0);
    const GREEN = new RGB(0.0, 1.0, 0.0);
    const BLUE = new RGB(0.0, 0.0, 1.0);
    const YELLOW = new RGB(1.0, 1.0, 0.0);
    const MAGENTA = new RGB(1.0, 0.0, 1.0);
    const CYAN = new RGB(0.0, 1.0, 1.0);
    const WHITE = new RGB(1.0, 1.0, 1.0);
    const GREY = new RGB(0.5, 0.5, 0.5);
    const ORANGE = new RGB(1.0, 0.5, 0.0);
    const PURPLE = new RGB(0.5, 0.0, 0.5);
    const PINK = new RGB(1.0, 0.5, 0.5);
    const BROWN = new RGB(0.5, 0.25, 0.0);
    const LIME = new RGB(0.6, 0.9, 0.2);
}