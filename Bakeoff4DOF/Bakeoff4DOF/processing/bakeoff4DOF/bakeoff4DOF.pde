import processing.sound.*;

import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window, set later
int trialCount = 12; //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int successes = 0; //used to keep track of number of successes
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done
SoundFile hit;
SoundFile miss;

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 500;
float logoY = 500;
float logoZ = 50f;
float logoRotation = 0;
float rotateButtonX = logoX + logoZ / 2 + 30; // Adjust the distance from the logo square as needed
float rotateButtonY = logoY; // Adjust the vertical position as needed
float rotateButtonSize = 40; // Adjust the size of the button as needed


boolean dragging = false;
float offsetX, offsetY;

private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Destination> destinations = new ArrayList<Destination>();

void setup() {
  size(1000, 800);  
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);
  rectMode(CENTER); //draw rectangles not from upper left, but from the center outwards
  
  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches
  
  // sound files for hits and misses
  hit = new SoundFile(this, "hit_sound.wav");
  miss = new SoundFile(this, "miss_sound.wav");

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Destination d = new Destination();
    d.x = random(border, width-border); //set a random x with some padding
    d.y = random(border, height-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
}
int submit_button_x = width/2;
int submit_button_y = height/2;
int submit_button_width = 100;
int submit_button_height = 50;

/* void draw_submit_button()
  {
    color button_color;
    if (checkForSuccess()){
      button_color = color(255, 0, 0);
    }
    else{
      button_color = color(0, 255, 0);
    }
    fill(button_color);
    rect(submit_button_x, submit_button_y, submit_button_width, submit_button_height);
    
    // Make Button Text White
    fill(255);
    textAlign(CENTER, CENTER);
    text("Submit", submit_button_x, submit_button_y);
  }
*/

color button_color;

void draw() {

  background(40); //background is dark grey
  fill(200);
  noStroke();

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    Destination d = destinations.get(i); //get destination trial
    translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
    rotate(radians(d.rotation)); //rotate around the origin of the destination trial
    noFill();
    strokeWeight(3f);
    if (trialIndex==i)
      stroke(255, 0, 0, 192); //set color to semi translucent
    else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.z, d.z);
    popMatrix();
  }

  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  translate(logoX, logoY); //translate draw center to the center of the logo square
  rotate(radians(logoRotation)); //rotate using the logo square as the origin
  noStroke();
  fill(60, 60, 192, 192);
  rect(0, 0, logoZ, logoZ);
  popMatrix();

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  scaffoldControlLogic(); //you are going to want to replace this!
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
  
  //===========DRAW SUBMIT BUTTON=====================
  if (!checkForSuccess()){
    button_color = color(255, 0, 0);
  }
  else{
    button_color = color(0, 255, 0);
  }
  fill(button_color);
  int submit_button_width = 100;
  int submit_button_height = 50;
  int submit_button_x = width/2;
  int submit_button_y = height/2;
  rect(submit_button_x, submit_button_y, submit_button_width, submit_button_height);
  
  // Make Button Text White
  fill(255);
  textAlign(CENTER, CENTER);
  text("Submit", submit_button_x, submit_button_y);
  
  //===========DRAW SUCCESSES AND ERRORS=====================
  textAlign(LEFT);
  fill(255);
  text("Hits: " + successes,40, 70);
  text("Errors: " + errorCount,40, 90);
  textAlign(CENTER);
  
  // Update button position with logo position
  float buttonSize = logoZ / 2; // Adjust the size of the button relative to the logo size
  rotateButtonX = logoX;
  rotateButtonY = logoY - logoZ / 2 - buttonSize / 2; // Adjust the vertical position

  // Draw circular button
  fill(255);
  ellipse(rotateButtonX, rotateButtonY, buttonSize, buttonSize);

  // Draw arrow icons for rotating logo square
  fill(0);
  float arrowSize = buttonSize / 3;
  float arrowOffset = buttonSize / 3.25; // Spacing Between Clockwise and Counter Clockwise arrows
  float arrowTopY = rotateButtonY - arrowOffset;
  float arrowLeftX = rotateButtonX - arrowSize / 2;
  float arrowRightX = rotateButtonX + arrowSize / 2;
  float arrowBottomY = rotateButtonY + arrowSize / 2 - arrowOffset;

  triangle(arrowLeftX - arrowSize / 4, arrowTopY, arrowRightX - arrowSize / 4, arrowTopY, rotateButtonX - arrowSize / 4, arrowTopY - arrowSize / 2);
  triangle(arrowLeftX + arrowSize / 4, arrowBottomY, arrowRightX + arrowSize / 4, arrowBottomY, rotateButtonX + arrowSize / 4, arrowBottomY + arrowSize / 2);

  // Check for button click
  float distance = dist(mouseX, mouseY, rotateButtonX, rotateButtonY);
  if (distance < buttonSize / 2 && mousePressed) {
    // Check if the mouse is on the right or left side of the button to determine the direction of rotation
    if (mouseX < rotateButtonX) {
      logoRotation -= 2; // Adjust the rotation speed as needed
    } else {
      logoRotation += 2; // Adjust the rotation speed as needed
    }
  }
}

//my example design for control, which is terrible
void scaffoldControlLogic()
{
  //upper left corner, rotate counterclockwise
  text("CCW", inchToPix(.4f), inchToPix(.4f));
  if (mousePressed && dist(0, 0, mouseX, mouseY)<inchToPix(.8f))
    logoRotation--;

  //upper right corner, rotate clockwise
  text("CW", width-inchToPix(.4f), inchToPix(.4f));
  if (mousePressed && dist(width, 0, mouseX, mouseY)<inchToPix(.8f))
    logoRotation++;

  //lower left corner, decrease Z
  text("-", inchToPix(.4f), height-inchToPix(.4f));
  if (mousePressed && dist(0, height, mouseX, mouseY)<inchToPix(.8f))
    logoZ = constrain(logoZ-inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone!

  //lower right corner, increase Z
  text("+", width-inchToPix(.4f), height-inchToPix(.4f));
  if (mousePressed && dist(width, height, mouseX, mouseY)<inchToPix(.8f))
    logoZ = constrain(logoZ+inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone! 

  //left middle, move left
  text("left", inchToPix(.4f), height/2);
  if (mousePressed && dist(0, height/2, mouseX, mouseY)<inchToPix(.8f))
    logoX-=inchToPix(.02f);

  text("right", width-inchToPix(.4f), height/2);
  if (mousePressed && dist(width, height/2, mouseX, mouseY)<inchToPix(.8f))
    logoX+=inchToPix(.02f);

  text("up", width/2, inchToPix(.4f));
  if (mousePressed && dist(width/2, 0, mouseX, mouseY)<inchToPix(.8f))
    logoY-=inchToPix(.02f);

  text("down", width/2, height-inchToPix(.4f));
  if (mousePressed && dist(width/2, height, mouseX, mouseY)<inchToPix(.8f))
    logoY+=inchToPix(.02f);
}

void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
  float halfSize = logoZ / 2;
  if (mouseX > logoX - halfSize && mouseX < logoX + halfSize && mouseY > logoY - halfSize && mouseY < logoY + halfSize) {
    dragging = true;
    offsetX = mouseX - logoX;
    offsetY = mouseY - logoY;
  }
}

void mouseDragged() {
  if (dragging) {
    logoX = mouseX - offsetX;
    logoY = mouseY - offsetY;
  }
}

void mouseReleased()
{
  dragging = false;
  int submit_button_width = 100;
  int submit_button_height = 50;
  int submit_button_x = width/2;
  int submit_button_y = height/2;
  //check to see if user clicked on Submit Button
  if ( (mouseX >= submit_button_x-submit_button_width/2 && mouseX <= (submit_button_x + submit_button_width/2)) && 
      (mouseY >= submit_button_y-submit_button_height/2 && mouseY <= (submit_button_y + submit_button_height/2)) )
  {
    if (userDone==false && !checkForSuccess())
      {
        miss.play();
        errorCount++;
      }
    else { 
        hit.play();
        successes++;
      }

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);	
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"	

  println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
  println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
  println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}
