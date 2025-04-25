public static class DithererJJNBW {

  private DithererJJNBW() {}

  public static PImage dither(PApplet papplet, PImage inputImage, float errorScale) {
    int w = inputImage.width;
    int h = inputImage.height;
    PImage result = papplet.createImage(w, h, PConstants.RGB);
    result.loadPixels();
    inputImage.loadPixels();

    float[][] greyscale = new float[h][w];

    // Convertendo para tons de cinza
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        color c = inputImage.pixels[y * w + x];
        float r = papplet.red(c);
        float g = papplet.green(c);
        float b = papplet.blue(c);
        greyscale[y][x] = 0.299f*r + 0.587f*g + 0.114f*b;
      }
    }

    int[][] diffusionMatrix = {
      {0, 0, 7, 5},
      {3, 5, 7, 5, 3},
      {1, 3, 5, 3, 1}
    };

    int[] dx = {-2, -1, 0, 1, 2};
    int[] dy = {0, 1, 2};

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        float oldPixel = greyscale[y][x];
        float newPixel = oldPixel < 128 ? 0 : 255;
        float quantError = oldPixel - newPixel;
        greyscale[y][x] = newPixel;

        for (int dyIndex = 0; dyIndex < dy.length; dyIndex++) {
          int ny = y + dy[dyIndex];
          if (ny < 0 || ny >= h) continue;

          for (int dxIndex = 0; dxIndex < diffusionMatrix[dyIndex].length; dxIndex++) {
            int offset = dxIndex + (dx.length - diffusionMatrix[dyIndex].length) / 2;
            int nx = x + dx[offset];
            if (nx < 0 || nx >= w) continue;

            greyscale[ny][nx] += quantError * diffusionMatrix[dyIndex][dxIndex] / 48.0f * errorScale;
          }
        }
      }
    }

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        float c = papplet.constrain(greyscale[y][x], 0, 255);
        result.pixels[y * w + x] = papplet.color(c);
      }
    }

    result.updatePixels();
    return result;
  }
}
