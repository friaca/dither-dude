static class DithererFloydSteinbergBW {

  static PImage dither(PApplet app, PImage img, float threshold, boolean serpentine) {
    img.loadPixels();
    int w = img.width;
    int h = img.height;

    float[][] pixels = new float[h][w];

    // Convert to grayscale float array
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        color c = img.pixels[y * w + x];
        float gray = app.red(c) * 0.299 + app.green(c) * 0.587 + app.blue(c) * 0.114;
        pixels[y][x] = gray;
      }
    }

    // Apply Floyd–Steinberg dithering with optional serpentine scanning
    for (int y = 0; y < h; y++) {
      if (serpentine && y % 2 == 1) {
        // Right to left
        for (int x = w - 1; x >= 0; x--) {
          float oldPixel = pixels[y][x];
          float newPixel = oldPixel < threshold ? 0 : 255;
          float error = oldPixel - newPixel;
          pixels[y][x] = newPixel;

          distributeError(pixels, x - 1, y    , error, 7f / 16);
          distributeError(pixels, x + 1, y + 1, error, 3f / 16);
          distributeError(pixels, x    , y + 1, error, 5f / 16);
          distributeError(pixels, x - 1, y + 1, error, 1f / 16);
        }
      } else {
        // Left to right
        for (int x = 0; x < w; x++) {
          float oldPixel = pixels[y][x];
          float newPixel = oldPixel < threshold ? 0 : 255;
          float error = oldPixel - newPixel;
          pixels[y][x] = newPixel;

          distributeError(pixels, x + 1, y    , error, 7f / 16);
          distributeError(pixels, x - 1, y + 1, error, 3f / 16);
          distributeError(pixels, x    , y + 1, error, 5f / 16);
          distributeError(pixels, x + 1, y + 1, error, 1f / 16);
        }
      }
    }

    // Build final dithered image
    PImage result = app.createImage(w, h, RGB);
    result.loadPixels();
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        int val = app.constrain((int)pixels[y][x], 0, 255);
        result.pixels[y * w + x] = app.color(val);
      }
    }
    result.updatePixels();

    return result;
  }

  static void distributeError(float[][] pixels, int x, int y, float error, float factor) {
    int h = pixels.length;
    int w = pixels[0].length;
    if (x < 0 || x >= w || y < 0 || y >= h) return;
    pixels[y][x] += error * factor;
  }
}
