import gab.opencv.*;
import processing.video.*;

Capture video;
Capture cam;
OpenCV opencv;
PImage bg;
PImage famousBg;
PImage colorPix;
PImage threshImg;
boolean takeSnapshot = false;
int videoWidth = 1024;
int videoHeight = 768;
int randImage = 1;
int threshold = 20;
int blur = 10;

void setup() {

  size(1700, 1169, P2D);
  
  String[] cameras = Capture.list();
  println(cameras);
  //video = new Capture(this, cameras[1]);//videoWidth, videoHeight);
  video = new Capture(this, videoWidth, videoHeight);//, "Webcam C170", 30);
  video.start(); 
 
  opencv = new OpenCV(this, videoWidth, videoHeight);
  bg = createImage(videoWidth, videoHeight, RGB); // creating initial image
  colorPix = createImage(videoWidth, videoHeight, ARGB);
  threshImg = createImage(videoWidth, videoHeight, RGB);
  famousBg = loadImage("_0" + 1 + ".jpg");

}

void draw() {
  background(255,0,0);

  opencv.loadImage(video);
  //opencv.flip(1);
  
  // takes background capture
  if (takeSnapshot) {
    bg = opencv.getSnapshot();
    takeSnapshot = false;
  }
   opencv.blur(blur);

  // makes differencing between bg and current
  opencv.diff(bg);
  opencv.threshold(threshold);
  opencv.erode();
  opencv.erode();
  //opencv.dilate();

  // copy color pixels where threshold image is white
  threshImg = opencv.getOutput();
  threshImg.loadPixels();
  if ((minute()*60+second())%30==0){ // every 30 sec. we're changing background << called modulo operator 
    randImage = (int) random(1,4);
    //famousBg = loadImage("background"+File.separator+"_0" + randImage + ".jpg");
    //famousBg = loadImage("_0" + randImage + ".jpg");

  }
  famousBg.loadPixels();
  
  for (int i = 0; i < videoWidth*videoHeight; i++) {
    float bright = brightness(threshImg.pixels[i]);
    if (bright >= 255) {
      colorPix.pixels[i] = video.pixels[i];
    } else {
      //colorPix.pixels[i] = famousBg.pixels[i]; 
      colorPix.pixels[i] = color(255,255,255,0);
    }
  }
  colorPix.updatePixels();
  
  // draw color pixel areas
  image(famousBg,0,0);
  image(colorPix, 850,200,225,300);//, width, height); // width and height for screen projecting to
  //image(video, 450,300,200,350);//, width, height); // width and height for screen projecting to

  //image(colorPix, 0, 0,width,height); // width and height for screen projecting to


  strokeWeight(3);
  ArrayList<Contour>contours = opencv.findContours(false, true);
  for (int i = 0; i < contours.size(); i++) {

    Contour contour = contours.get(i);

    // use this to stop if area too small
    if ( contour.area() < 300 ) {
      break;
    }

    contour.setPolygonApproximationFactor(4);

    noFill();
    stroke(255, 0, 0);
    //contour.getPolygonApproximation().draw();

    float centerX = contour.getBoundingBox().x + contour.getBoundingBox().width*.5;
    float centerY = contour.getBoundingBox().y + contour.getBoundingBox().height*.5;

    //noStroke();
    //fill(255, 0, 255);
    //ellipse(centerX, centerY, 10, 10);
  }
}

void keyPressed() {
  if(key ==' '){takeSnapshot = true;}
  else if(key =='+') { threshold++;}
  else if(key =='-') { threshold--;}
  else if(key =='b') {blur++;}
  else if(key == 'u') {blur--;}
  
}

