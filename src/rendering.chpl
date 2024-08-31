module Rendering {

    import Colour.RGB;
    import Colour;
    use IO;
    use FileSystem;
    
    record Image {
        var width: uint;
        var height: uint;
        var pixels: [0..<width, 0..<height] RGB;
    }

    proc Image.init(width: uint, height: uint) {
        this.width = width;
        this.height = height;
        this.pixels = [0..<width, 0..<height] Colour.BLACK;
    }

    proc Image.save(filename: string) {
        try {
            var fi = open(filename, ioMode.cw);
            var f = fi.writer(locking=false);
            f.writef("P3\n%i %i\n255\n", width, height);
            for x in 0..<width {
                for y in 0..<height {        
                    pixels[x, y].print(f);
                }
            }
            f.close();
        }
        catch e: Error {
            writeln("Error saving image: ", e);
        }
    }

    record Render {
        var colour: Image;
        var normal: Image;
        var time_taken: Image;
    }

    proc Render.save(dir_name: string) {
        try {
            mkdir(dir_name);
        }
        catch e: Error {
            writeln("Error creating directory: ", e);
        }
        colour.save(dir_name + "/colour.ppm");
        normal.save(dir_name + "/normal.ppm");
        time_taken.save(dir_name + "/time_taken.ppm");
    }

}