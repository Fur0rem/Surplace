module MaterialModule {

    use Colour;

    record Material {
        var col: RGB; // TODO: rename to colour
        var alpha: real(64);
        var emission: real(64);
    }

    proc Material.init(r: real(64), g: real(64), b: real(64), a: real(64), emission: real(64)) {
        this.col = RGB(r, g, b);
        this.alpha = a;
        this.emission = emission;
    }

    proc Material.init(col: RGB, alpha: real(64), emission: real(64)) {
        this.col = col;
        this.alpha = alpha;
        this.emission = emission;
    }

    proc Material.init() {
        this.col = BLACK;
        this.alpha = 1.0;
        this.emission = 0.0;
    }

    // TODO: how tf do we do static methods in this language
    proc Material_interpolate(a: Material, b: Material, t: real(64)): Material {
        return new Material(
            col = a.col.interpolate(b.col, t),
            alpha = a.alpha + (b.alpha - a.alpha) * t,
            emission = a.emission + (b.emission - a.emission) * t
        );
    }

}