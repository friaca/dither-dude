static class DithererFloydSteinberg {

  static PImage dither(PApplet app, PImage img, color[] palette) {
    img.loadPixels();

    int w = img.width;
    int h = img.height;

    float[][][] pixels = new float[h][w][3];

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        int c = img.pixels[y * w + x];
        pixels[y][x][0] = app.red(c);
        pixels[y][x][1] = app.green(c);
        pixels[y][x][2] = app.blue(c);
      }
    }

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        float[] oldPixel = pixels[y][x];
        color nearest = findNearestColor(app, oldPixel, palette);

        float[] newPixel = {
          app.red(nearest),
          app.green(nearest),
          app.blue(nearest)
        };

        float[] error = {
          oldPixel[0] - newPixel[0],
          oldPixel[1] - newPixel[1],
          oldPixel[2] - newPixel[2]
        };
        
        pixels[y][x] = newPixel;

        distributeError(pixels, x + 1, y,     error, 7f / 16);
        distributeError(pixels, x - 1, y + 1, error, 3f / 16);
        distributeError(pixels, x,     y + 1, error, 5f / 16);
        distributeError(pixels, x + 1, y + 1, error, 1f / 16);
      }
    }

    // Create output PImage
    PImage result = app.createImage(w, h, RGB);
    result.loadPixels();
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        int r = app.constrain((int) pixels[y][x][0], 0, 255);
        int g = app.constrain((int) pixels[y][x][1], 0, 255);
        int b = app.constrain((int) pixels[y][x][2], 0, 255);
        result.pixels[y * w + x] = app.color(r, g, b);
      }
    }
    result.updatePixels();

    return result;
  }

  static void distributeError(float[][][] pixels, int x, int y, float[] error, float factor) {
    int h = pixels.length;
    int w = pixels[0].length;
    if (x < 0 || x >= w || y < 0 || y >= h) return;
    for (int i = 0; i < 3; i++) {
      pixels[y][x][i] += error[i] * factor;
    }
  }

  static color findNearestColor(PApplet app, float[] rgb, color[] palette) {
    double minDist = Double.MAX_VALUE;
    color nearest = palette[0];
    for (color c : palette) {
      double dist = colorDistance(app, rgb, c);
      if (dist < minDist) {
        minDist = dist;
        nearest = c;
      }
    }
    return nearest;
  }

  static double colorDistance(PApplet app, float[] rgb, color c) {
    double dr = rgb[0] - app.red(c);
    double dg = rgb[1] - app.green(c);
    double db = rgb[2] - app.blue(c);
    return dr * dr + dg * dg + db * db;
  }
}
