import com.krab.lazy.*;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Random;

LazyGui gui;
PImage originalImage;
PGraphics buffer;

Path originalImagePath;
Random rng = new Random();
boolean imageNeedsBuffer = false;

void setup() {
  size(1200, 800, P2D);
  gui = new LazyGui(this, new LazyGuiSettings()
    .setHideBuiltInFolders(true));
}

void imageSelected(File file) {
  if (file == null) {
    println("No file selected.");
    return;
  }

  println("File selected: " + file.getAbsolutePath());

  originalImagePath = Paths.get(file.getAbsolutePath());
  originalImage = loadImage(file.getAbsolutePath());
  imageNeedsBuffer = true;
}

String getRandomNumberAsString(int upperLimit) {
  return Integer.toString(rng.nextInt(upperLimit) + 1);
}

void saveImage() {
  if (buffer == null) {
    println("No image selected, skipping action");
    return;
  }

  String outputPath = originalImagePath
    .getParent()
    .resolve("exported_image" + getRandomNumberAsString(1000) + ".png")
    .toAbsolutePath()
    .toString();

  println("Saved at " + outputPath);
  buffer.save(outputPath);
}

void ditherImage() {
  color[] palette = {
    color(0, 0, 0),
    color(255, 255, 255),
    color(255, 0, 0),
    color(0, 255, 0),
    color(0, 0, 255)
  };

  //PImage dithered = DithererFloydSteinberg.dither(this, originalImage, palette);
  PImage dithered = DithererFloydSteinbergBW.dither(this, originalImage, 128, false);

  updateBuffer(dithered);
}

void updateBuffer(PImage image) {
  buffer = createGraphics(image.width, image.height, P2D);

  buffer.beginDraw();
  buffer.image(image, 0, 0);
  buffer.endDraw();
}

void drawImageFit(PImage img) {
  float imgAspect = float(img.width) / img.height;
  float canvasAspect = float(width) / height;

  float w, h;
  if (imgAspect > canvasAspect) {
    w = width;
    h = width / imgAspect;
  } else {
    h = height;
    w = height * imgAspect;
  }

  float x = (width - w);
  float y = (height - h);

  image(img, x, y, w, h);
}

void draw() {
  background(0);

  boolean selectImageClicked = gui.button("select image");
  boolean ditherImageClicked = gui.button("do it");
  boolean saveImageClicked = gui.button("save image");

  if (selectImageClicked) {
    selectInput("Select an image", "imageSelected");
  }

  if (saveImageClicked) {
    saveImage();
  }

  if (originalImage != null && imageNeedsBuffer) {
    updateBuffer(originalImage);
    imageNeedsBuffer = false;
  }

  if (ditherImageClicked && originalImage != null && !imageNeedsBuffer) {
    ditherImage();
  }

  if (buffer != null) {
    drawImageFit(buffer);
  }
}