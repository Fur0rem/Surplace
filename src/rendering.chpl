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
        var ambient_occlusion: Image;
        var time_taken: Image;
    }

    proc Render.combine_renders(): Image {
        var final_render = new Image(colour.width, colour.height);
        for x in 0..<colour.width {
            for y in 0..<colour.height {
                var amb_occ = ambient_occlusion.pixels[x, y].r;
                amb_occ = amb_occ * 0.5 + 0.5;
                final_render.pixels[x, y] = colour.pixels[x, y] * amb_occ;
            }
        }
        return final_render;
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
        ambient_occlusion.save(dir_name + "/ambient_occlusion.ppm");
        time_taken.save(dir_name + "/time_taken.ppm");
        combine_renders().save(dir_name + "/final_render.ppm");
    }

}