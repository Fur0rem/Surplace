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
}