void renderImage(PImage img, float scale) {

  beginShape();
  texture(img);

  vertex(-0.5*img.width*scale, -0.5*img.height*scale, 0, 0);
  vertex(0.5*img.width*scale, -0.5*img.height*scale, img.width, 0);
  vertex(0.5*img.width*scale, 0.5*img.height*scale, img.width, img.height);
  vertex(-0.5*img.width*scale, 0.5*img.height*scale, 0, img.height);

  endShape();
}


float getDistanceToCam(float[] position, QueasyCam cam) {

  return dist(position[0], position[1], position[2], cam.position.x, cam.position.y, cam.position.z);
}


void updateSoundscape(AudioPlayer sound, float[] position, QueasyCam cam, float k) {

  sound.setGain(-(getDistanceToCam(position_sculp, cam)*k));
  beta = atan2((position[2]-cam.position.z), (position[0]-cam.position.x))-cam.pan;
  sound.setBalance(sin(beta));
}


void updateSoundscape_wave(AudioOutput out, float[] position, QueasyCam cam, float k) {

  out.setGain(-(getDistanceToCam(position_sculp, cam)*k));
  beta = atan2((position[2]-cam.position.z), (position[0]-cam.position.x))-cam.pan;
  out.setBalance(sin(beta));
}

void waveFadeIn(Oscil wave, int fadeInStartFrameCount, int currentFrameCount, int fadeInDurationFrames) {

  //int fadeInDurationFrames = 100;
  int frameElapsed = currentFrameCount - fadeInStartFrameCount;

  if (frameElapsed>=0&&frameElapsed<fadeInDurationFrames) {
    float fadeInSlope =1.0f/fadeInDurationFrames;
    float amp = frameElapsed*fadeInSlope;
    amp = constrainFloat(amp, 0.0f, 1.0f);
    wave.setAmplitude(amp);  //amp is between 0 and 1
  }
}

void waveFadeOut(Oscil wave, int fadeOutStartFrameCount, int currentFrameCount, int fadeOutDurationFrames) {

  //int fadeOutDurationFrames = 100;
  int frameElapsed = currentFrameCount - fadeOutStartFrameCount;

  if (frameElapsed>=0&&frameElapsed<fadeOutDurationFrames) {
    float fadeOutSlope = 1.0f/fadeOutDurationFrames;
    float amp = 1.0f-frameElapsed*fadeOutSlope;
    amp = constrainFloat(amp, 0.0f, 1.0f);
    wave.setAmplitude(amp);  //amp is between 0 and 1
  }
}



float constrainFloat(float input, float min, float max) {

  float output = input;
  if (input>max) {
    output = max;
  } else if (input<min) {
    output = min;
  }

  return output;
}


void keyPressed()
{
  String keystr=String.valueOf(key);
  int num = int(keystr);
  if ( num > 0 && num < 10 )
  {

    bgm_1.loop(num);
    bgm_2.loop(num);
    sculpture.loop(num);
    sevenseas.loop(num);
    trail.loop(num);
    sunrise.loop(num);
   
    loopcount = num;
    println(loopcount);
  }
}