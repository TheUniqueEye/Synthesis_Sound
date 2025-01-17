
/* 2016-12-5 
 Music and Technology (200B)
 
 ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 :::::::::::  SEVEN DOORS - soundscape of the Art Museum ::::::::::
 ::::::::::::::::::::::::::::::::::::::::::: code: Jing Yan :::::::
 ::::::::::::::::::: theuniqueeye@gmail.com :::::::::::::::::::::::
 ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 ::::::: [FINAL VERSION 4] ::::::::::::::::::::::::::::::::::::::::
 
 / The project intends to build a virtual soundscape of an art museum.
 As a prototype, it is based on the works and atmosphere of Santa Barbara 
 Art Museum's 75th anniversary exhibition: SEVEN DOORS presented by artist Jan Tichy. 
 
 / Based on the existing art works, the sound source presented in the room including:
 an electronic music generated by doing dynamic thresholding of the image,
 (which is inspired by the aesthetic of György Ligeti's sound mass music)
 several ambient sounds of the room recorded by myself,
 water, sea, and mountain sound files from freesound,
 an 1:30 min excerpt from Stockhausen's "Four Criteria of Electronic Music"
 
 / Users can navigate through the virtual space with keyboard and mouse interaction
 and hear the spatial sound changes in different area of the room. 
 
 / Interaction Control: 
 using "A,D" to control moving left and right
 using "W,S" to control moving forward and back
 using mouse pointer to control facing orientation
 
 */


import queasycam.*;

import ddf.minim.*;
import ddf.minim.ugens.*;

import java.util.*;  // to sort with Collections

QueasyCam cam;
float counter;
PImage img_sevenseas, img_trail, img_sunrise;
PImage img_sevenseas_thres, img_sevenseas_thres_prev, img_sevenseas_d;
int subtractPixelCounter = 0;
float thres = -1.0f; //to make the ini frame all white

float roomLength = 60;
float roomWidth = 40;
float roomHeight = 30;
float nailLength = 0.05;

float [] position_bgm_1 = {(roomLength/3.0-nailLength), 0, -(roomWidth/3.0-nailLength)};
float [] position_bgm_2 = {0, 0, 0};
float [] position_bgm_3 = {-(roomLength/3.0-nailLength), 0, 0};
float [] position_bgm_4 = {-(roomLength/3.0-nailLength), 0, (roomWidth/3.0-nailLength)};
float [] position_sculp = {-20, roomHeight/2-5, -10};
float [] position_sevenseas = {(roomLength/2.0-nailLength), 0, 0};
float [] position_trail = {10, 0, (roomWidth/2.0-nailLength)};
float [] position_sunrise = {-15, 0, (roomWidth/2.0-nailLength)};

float beta = 0.0;

float oldFreq = 0.0f;
float newFreq = 0.0f;
int freqSwitch = 0;

int fadeInNOutDuration = 60;
int fadeInNOutStartFrame = 0;

int loopcount =0;

AudioPlayer bgm_1;
AudioPlayer bgm_2;
AudioPlayer bgm_3;
AudioPlayer bgm_4;
AudioPlayer sculpture;
AudioPlayer sevenseas;
AudioPlayer trail;
AudioPlayer sunrise;

Minim minim;
AudioOutput out;
Oscil     wave1;
Oscil     wave2;
Oscil     wave3;
Oscil     wave4;

void setup() {

  //size(1200, 400, P3D);
  fullScreen(P3D);
  noCursor();

  cam = new QueasyCam(this);
  cam.sensitivity = 0.5;
  cam.speed = 0.05;
  perspective(PI/4, (float)width/height, 0.01, 10000);

  // set light
  //directionalLight(0, 0, 0, 0, 1, 0); // light from right top
  //ambientLight(0, 0, 0);

  //ini
  minim = new Minim(this);
  counter = 0;

  //loading zone
  img_sevenseas = loadImage("painting_3.jpg");
  img_sevenseas_thres = createImage(img_sevenseas.width, img_sevenseas.height, RGB);
  img_sevenseas_thres_prev = createImage(img_sevenseas.width, img_sevenseas.height, RGB);
  img_sevenseas_d = createImage(img_sevenseas.width, img_sevenseas.height, RGB);

  img_trail = loadImage("trail.jpg");
  img_sunrise = loadImage("sunrise.jpg");


  bgm_1 = minim.loadFile("room_1.mp3", 2048);
  bgm_2 = minim.loadFile("room_2.mp3", 2048);
  bgm_3 = minim.loadFile("room_3.mp3", 2048);
  //bgm_4 = minim.loadFile("room_4.mp3", 2048);
  sculpture = minim.loadFile("stockhausen_01.wav", 2048);
  sevenseas = minim.loadFile("sevenseas_01.wav", 2048);
  trail = minim.loadFile("water_01.wav", 2048);
  sunrise = minim.loadFile("snow_01.wav", 2048);

  bgm_1.play();
  bgm_2.play();
  bgm_3.play();
  //bgm_4.play();
  sculpture.play();
  sevenseas.play();
  trail.play();
  sunrise.play();


  //sound
  // use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut();

  // create a sine wave Oscil, set to 440 Hz, at 0.5 amplitude
  wave1 = new Oscil( 0, 0.5f, Waves.SINE );
  wave2 = new Oscil( 0, 0.5f, Waves.SINE );
  wave3 = new Oscil( 0, 0.5f, Waves.SINE );
  wave4 = new Oscil( 0, 0.5f, Waves.SINE );

  // patch the Oscil to the output
  wave1.patch( out );
  wave1.setAmplitude(0);
  wave2.patch( out );
  wave2.setAmplitude(0);

  wave3.patch( out );
  wave3.setAmplitude(0);
  wave4.patch( out );
  wave4.setAmplitude(0);
}

void draw() {
  background(50);

  //updateSoundscape(bgm_1, position_bgm_1, cam, 1.50);
  //updateSoundscape(bgm_2, position_bgm_2, cam, 1.50);
  //updateSoundscape(bgm_3, position_bgm_3, cam, 1.50);
  //updateSoundscape(bgm_4, position_bgm_4, cam, 1.50);
  updateSoundscape(sculpture, position_sculp, cam, 0.50);
  updateSoundscape(sevenseas, position_sevenseas, cam, 0.7);
  updateSoundscape(trail, position_trail, cam, 0.6);
  updateSoundscape(sunrise, position_sunrise, cam, 0.3);



  //updating sine waves

  //freq update
  if (frameCount%(fadeInNOutDuration+30)==0) {
    fadeInNOutStartFrame = frameCount;
    println("freq updated! fadeInNOutStartFrame = "+fadeInNOutStartFrame);
    oldFreq = newFreq;
    newFreq  = 10000.0f*subtractPixelCounter/(img_sevenseas.width*img_sevenseas.height);
    newFreq = map(newFreq, 0, 100, 0, 400);
    freqSwitch++;
    if (freqSwitch%2==1) {
      wave1.setFrequency(oldFreq);
      wave2.setFrequency(newFreq);
      //wave3.setFrequency(oldFreq*2);
      //wave4.setFrequency(newFreq*2);
      println("wave1 freq  = "+oldFreq+", wave2 freq  = "+newFreq);
    } else {
      wave1.setFrequency(newFreq);
      wave2.setFrequency(oldFreq);
      //wave3.setFrequency(newFreq*2);
      //wave4.setFrequency(oldFreq*2);
      println("wave1 freq  = "+newFreq+", wave2 freq  = "+oldFreq);
    }
  }

  //fade
  if (freqSwitch%2==1) {
    waveFadeIn(wave2, fadeInNOutStartFrame, frameCount, fadeInNOutDuration);
    waveFadeOut(wave1, fadeInNOutStartFrame, frameCount, fadeInNOutDuration);
    waveFadeIn(wave3, fadeInNOutStartFrame, frameCount, fadeInNOutDuration);
    waveFadeOut(wave4, fadeInNOutStartFrame, frameCount, fadeInNOutDuration);
    println("fade 1 ");
  } else {
    waveFadeIn(wave1, fadeInNOutStartFrame, frameCount, fadeInNOutDuration);
    waveFadeOut(wave2, fadeInNOutStartFrame, frameCount, fadeInNOutDuration);
    waveFadeIn(wave3, fadeInNOutStartFrame, frameCount, fadeInNOutDuration);
    waveFadeOut(wave4, fadeInNOutStartFrame, frameCount, fadeInNOutDuration);
    println("fade 2 ");
  }

  //updateSoundscape_wave(out, position_sevenseas, cam, 0.31);
  // println("frameCount = "+frameCount);
  //end of updating sine waves

  //println("beta = "+beta);
  //println("sin(beta) = "+sin(beta));

  //println("cam position = "+cam.position);
  //println("position_sculp = "+position_sculp[0]+", "+position_sculp[1]+", "+position_sculp[2]);
  //println("distance = "+getDistanceToCam(position_sculp,cam));


  //sculpture.loop();
  counter += 1;

  // room

  fill(220);
  strokeWeight(2);
  stroke(150);
  box(roomLength, roomHeight, roomWidth);


  //floor
  pushMatrix();
  fill(200);
  translate(-roomLength/2.0, (roomHeight/2.0-nailLength), -roomWidth/2.0);
  beginShape();
  vertex(0, 0, 0);
  vertex(roomLength, 0, 0);
  vertex(roomLength, 0, roomWidth);
  vertex(0, 0, roomWidth);
  endShape();
  popMatrix();
  noStroke();

  // art 1-4
  pushMatrix();

  translate(position_sevenseas[0], position_sevenseas[1], position_sevenseas[2]);
  rotateY(PI/2);



  if (frameCount%10==0) {
    // initiate subtractPixelCounter
    subtractPixelCounter = 0;

    //get img_sevenseas_thres
    // We are going to look at both image's pixels
    img_sevenseas.loadPixels();
    img_sevenseas_thres.loadPixels();
    img_sevenseas_d.loadPixels();

    for (int x = 0; x < img_sevenseas.width; x++) {
      for (int y = 0; y < img_sevenseas.height; y++ ) {
        int loc = x + y*img_sevenseas.width;
        // Test the brightness against the threshold
        if (brightness(img_sevenseas.pixels[loc]) > thres) {
          img_sevenseas_thres.pixels[loc]  = color(255);  // White
        } else {
          img_sevenseas_thres.pixels[loc]  = color(0);    // Black
        }

        //get derivative
        img_sevenseas_d.pixels[loc] = img_sevenseas_thres_prev.pixels[loc]-img_sevenseas_thres.pixels[loc];
        if (img_sevenseas_d.pixels[loc]>100) {
          subtractPixelCounter++;
        }
      }
    }

    // We changed the pixels in destination
    img_sevenseas_thres.updatePixels();
    img_sevenseas_d.updatePixels();
    println("subtractPixelCounter ratio = "+10000.0f*subtractPixelCounter/(img_sevenseas.width*img_sevenseas.height));
    img_sevenseas_thres_prev = img_sevenseas_thres.copy();


    if (thres<255) {
      thres++;
    } else {
      thres = -1.0f;
    }
  }



  if (frameCount==1) {
    img_sevenseas_thres_prev = img_sevenseas_thres.copy();
  }


  //renderImage(img_sevenseas_d, 0.02);
  renderImage(img_sevenseas_thres, 0.02);
  // renderImage(img_sevenseas, 0.02);

  //box(2);
  popMatrix();

  pushMatrix();
  translate(position_trail[0], position_trail[1], position_trail[2]);
  renderImage(img_trail, 0.005);
  popMatrix();

  pushMatrix();
  translate(position_sunrise[0], position_sunrise[1], position_sunrise[2]);
  renderImage(img_sunrise, 0.01);
  popMatrix();

  pushMatrix();
  fill(100, 200);
  translate(position_sculp[0], position_sculp[1], position_sculp[2]);
  box(2, 10, 2);
  popMatrix();
}