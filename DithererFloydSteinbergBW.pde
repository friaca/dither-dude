import processing.core.PApplet; 
import processing.core.PImage;

public static class DithererFloydSteinbergBW { 

  private DithererFloydSteinbergBW() {}

  public static PImage dither(PApplet papplet, PImage inputImage, boolean useSerpentine) { 
    if (inputImage == null) {
        PApplet.println("Error: Input image to dither is null."); 
        return null;
    }
     if (papplet == null) {
        PApplet.println("Error: PApplet instance (sketch) is null.");
        return null;
    }

    PImage img = inputImage.copy(); 
    int w = img.width;
    int h = img.height;

    img.loadPixels();
    float[][] grayBuffer = new float[h][w];

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        int index = y * w + x;
        grayBuffer[y][x] = papplet.brightness(img.pixels[index]); 
      }
    }

    for (int y = 0; y < h; y++) {

      boolean goingRight = !useSerpentine || (y % 2 == 0); // Go right if not serpentine or on even rows

      if (goingRight) {
        for (int x = 0; x < w; x++) {
          processPixel(papplet, img, grayBuffer, x, y, w, h, goingRight);
        }
      } else {
        for (int x = w - 1; x >= 0; x--) { 
          processPixel(papplet, img, grayBuffer, x, y, w, h, goingRight);
        }
      }
    }

    img.updatePixels();
    return img; 
  }

  private static void processPixel(PApplet papplet, PImage img, float[][] grayBuffer, int x, int y, int w, int h, boolean goingRight) {
      
      float oldGray = grayBuffer[y][x];
      float newGray = (oldGray < 200) ? 0.0f : 255.0f; 
      int index = y * w + x;

      img.pixels[index] = papplet.color(newGray); 

      float quantError = oldGray - newGray;

      if (goingRight) {
        if (x + 1 < w) { 
          grayBuffer[y][x + 1] += quantError * 7.0f / 16.0f; 
        }
        if (x - 1 >= 0 && y + 1 < h) { 
          grayBuffer[y + 1][x - 1] += quantError * 3.0f / 16.0f; 
        }
        if (y + 1 < h) { 
          grayBuffer[y + 1][x] += quantError * 5.0f / 16.0f; 
        }
        if (x + 1 < w && y + 1 < h) { 
          grayBuffer[y + 1][x + 1] += quantError * 1.0f / 16.0f; 
        }
      } else {
        if (x - 1 >= 0) { 
          grayBuffer[y][x - 1] += quantError * 7.0f / 16.0f; 
        }
        if (x + 1 < w && y + 1 < h) { 
          grayBuffer[y + 1][x + 1] += quantError * 3.0f / 16.0f; 
        }
        if (y + 1 < h) { 
          grayBuffer[y + 1][x] += quantError * 5.0f / 16.0f; 
        }
        if (x - 1 >= 0 && y + 1 < h) { 
          grayBuffer[y + 1][x - 1] += quantError * 1.0f / 16.0f; 
        }
      }
  }
}
