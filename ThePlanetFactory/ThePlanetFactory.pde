import controlP5.*;
import java.io.BufferedReader;
import java.io.InputStreamReader;

ControlP5 cp5;

PImage webImg;

Planet planet;
Planet sun;
PVector center;

float zoomFactor = 0.5;
String planet_name;
float mass, radius, temp, flux, distance, temp_type, gravity;
Textfield pl_name;
Button checker, continues;
Textarea habitable;
Slider Mass, Radius, Temp, Flux, Distance, Temp_type, Gravity;

float[] do_predict(float mass, float radius, float gravity, float distance, float flux, float temp, float temp_type) {
  String commandToRun = "/usr/local/bin/python3 main.py " + mass + " " + radius + " " + gravity + " " + distance + " " + flux + " " + temp + " " + temp_type;

  // where to do it - should be full path
  File workingDir = new File(sketchPath(""));

  // run the script!
  String returnedValues;
  //float[] r_floats = {0,0};
  try {
    Process p = Runtime.getRuntime().exec(commandToRun, null, workingDir);
    int i = p.waitFor();
    if (i == 0) {
      BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));
      while ( (returnedValues = stdInput.readLine ()) != null) {
        println(returnedValues);
        float[] r_floats = {Float.parseFloat(returnedValues.split("-")[0]), Float.parseFloat(returnedValues.split("-")[1])};
        return r_floats;
      }
    }

    // if there are any error messages but we can still get an output, they print here
    else {
      BufferedReader stdErr = new BufferedReader(new InputStreamReader(p.getErrorStream()));
      while ( (returnedValues = stdErr.readLine ()) != null) {
        println(returnedValues);
        float[] r_floats = {Float.parseFloat(returnedValues.split("-")[0]), Float.parseFloat(returnedValues.split("-")[1])};
        return r_floats;
      }
    }
  }

  // if there is any other error, let us know
  catch (Exception e) {
    println("Error running command!");
    println(e);
    // e.printStackTrace(); // a more verbose debug, if needed
  }
  float[] r_floats = {0,0};
  return r_floats;
}

void setup() {
  surface.setResizable(true);
  size(800, 480);
  //size(1920,1080);
  //String url = "https://www.jpl.nasa.gov/spaceimages/images/wallpaper/PIA00342-800x600.jpg";
  // Load image from a web server
  //webImg = loadImage(url, "jpg");  
  
  planet = new Planet();
  planet.eccentricity = 0.2;
  planet.temperature = 200;
  
  sun = new Planet();
  sun.orbitRadius = 0;
  sun.temperature = 6e3;
  sun.diameter = 200;
  
  cp5 = new ControlP5(this);
  fill(0);
  pl_name = cp5.addTextfield("planet_name").setColorBackground(color(255,40)).setColorForeground(color(255)).setColorValue(0);
  pl_name.getCaptionLabel().setVisible(false);
  
  checker = cp5.addButton("Check");
  habitable = cp5.addTextarea("Habitable?");
  continues = cp5.addButton("Continue").setVisible(false);
  
  Mass = cp5.addSlider("mass", 0.01906968, 17668.058999999997);
  Radius = cp5.addSlider("radius", 0.3363, 77.34899999999999);
  Temp = cp5.addSlider("temperature", 2.6881975, 7056.7757);
  Flux = cp5.addSlider("flux", 1.24e-08, 588634.37);
  Distance = cp5.addSlider("distance", 100, 2500.0);
  Temp_type = cp5.addSlider("temperature type", 0, 2).setNumberOfTickMarks(3);
  Gravity = cp5.addSlider("gravity", 0.044184663, 1254.4501);
  
}

void draw() {
  int[] im_size = {width/2, height/2};
  int[] label_size = {im_size[0], height/10};
  int border = (height - (im_size[1]+label_size[1]*3))/2;
  int slider_h = (height - 2*border)/8; 
  int slider_space = slider_h/6;
  center = new PVector(border + im_size[0]/2, border + im_size[1]/2);
  
  background(60);
  fill(255);
  
  planet.orbit();
  
  if (planet.orbit < PI) {
    sun.display(center);
    planet.display(center);
  } else {
    planet.display(center);
    sun.display(center);
  }
  
  ControlFont cf1 = new ControlFont(createFont("Arial",height/20));
  
  fill(255);
  textSize(height/15);
  text("The Planet Factory", border, border/1.5);
  textSize(height/20);
  
  stroke(255);
  strokeWeight(5);
  // rect(border, border, im_size[0], im_size[1]);
  //image(webImg,border,border,im_size[0], im_size[1]);
  fill(255);
  rect(border, im_size[1]+border, label_size[0], label_size[1]);
  fill(0);
  text("Planet Name:", border, im_size[1]+1.7*border);
  
  pl_name.setPosition(4.5*border, im_size[1]+border).setSize(im_size[0]-6*border, label_size[1]).setAutoClear(false).setFont(cf1);
  checker.setPosition(im_size[0] - border, im_size[1]+border).setSize(2*border, label_size[1]);
  continues.setPosition(im_size[0] - border, im_size[1]+ 3*label_size[1]).setSize(2*border, label_size[1]);
  habitable.setPosition(border, im_size[1]+1.5*label_size[1]+border).setSize(label_size[0],2*label_size[1]);
  habitable.setFont(cf1);
  
  // set position and size
  Mass.setPosition(im_size[0]+2*border, border).setSize(label_size[0]-4*border, slider_h);
  Radius.setPosition(im_size[0]+2*border, border+slider_h+slider_space).setSize(label_size[0]-4*border, slider_h);
  Temp.setPosition(im_size[0]+2*border, border+2*slider_h+2*slider_space).setSize(label_size[0]-4*border, slider_h);
  Flux.setPosition(im_size[0]+2*border, border+3*slider_h+3*slider_space).setSize(label_size[0]-4*border, slider_h);
  Distance.setPosition(im_size[0]+2*border, border+4*slider_h+4*slider_space).setSize(label_size[0]-4*border, slider_h);
  Temp_type.setPosition(im_size[0]+2*border, border+5*slider_h+5*slider_space).setSize(label_size[0]-4*border, slider_h);
  Gravity.setPosition(im_size[0]+2*border, border+6*slider_h+6*slider_space).setSize(label_size[0]-4*border, slider_h);
  
  // set min and max parameters
  
}

void controlEvent(ControlEvent theEvent) {
 /* events triggered by controllers are automatically forwarded to 
 the controlEvent method. by checking the name of a controller one can 
 distinguish which of the controllers has been changed.
 */ 
 
 /* check if the event is from a controller otherwise you'll get an error
 when clicking other interface elements like Radiobutton that don't support
 the controller() methods
 */
 
 if(theEvent.isController()) { 
 
 //print("control event from : "+theEvent.getController().getName());
 //println(", value : "+theEvent.getController().getValue());
 if(theEvent.getController().getName()=="distance"){
   sun.diameter = sqrt((25000/Distance.getValue()))*15;
   //print(sun.orbit);
 }
 if(theEvent.getController().getName()=="radius"){
   planet.diameter = sqrt(Radius.getValue())*10;
 }
 if(theEvent.getController().getName()=="temperature"){
   planet.temperature = Temp.getValue();
 }
 
 if(theEvent.getController().getName()=="Check" | theEvent.getController().getName()=="planet_name") {
    //print("this is the text you typed :");
    planet_name = pl_name.getText();
    mass = Mass.getValue();
    radius = Radius.getValue();
    temp = Temp.getValue();
    flux = Flux.getValue();
    distance = Distance.getValue();
    temp_type = Temp_type.getValue();
    gravity = Gravity.getValue();
    
    float[] a = do_predict(mass, radius, gravity, distance, flux, temp, temp_type); 
   //println(a);
   
   habitable_set(planet_name, a[0], a[1]);
   
    //habitable_set(planet_name, distance);
    //print(planet_name + " " + mass + " " + radius + " " + temp + " " + flux + " " + distance + " " + temp_type + " " + gravity);
 }
 
 } 
}

void habitable_set(String name, float classifier, float earthlike_index){
  if(classifier < 0.75){
    habitable.setText(name + " is NOT habitable! \nTry again...");  
    continues.setVisible(false);
  }
  else{
    int ei = int(earthlike_index*100);
    habitable.setText(name  + " is habitable! \nPlease Continue\nEarth Similarity: " + ei + "%");
    continues.setVisible(true);
  }
}


// Spinning planet
class Planet {
  PVector origin, position;
  float diameter, temperature;
  float orbit, orbitRadius, dt, eccentricity;
  
  Planet() {
    diameter = 100;
    temperature = 0;
    orbitRadius = 250;
    dt = 1e-2;
    eccentricity = 1;
    
    position = new PVector(0, 0);
    origin = new PVector(0,0);
  }
  
  color getColor() {
    color orange = color(255, 127, 39);
    color iceBlue = color(102, 198, 255);
    color rockGray = color(88, 88, 88);
    
    if (this.temperature < 263.15) { // FREEZING
      return iceBlue;
    } else if (this.temperature < 273.15) {
      float prog = (this.temperature - 263.15)/10;
      int red = (int)red(iceBlue) + round((red(rockGray)-red(iceBlue))*prog);
      int green = (int)green(iceBlue) + round((green(rockGray)-green(iceBlue))*prog);
      int blue = (int)blue(iceBlue) + round((blue(rockGray)-blue(iceBlue))*prog);
      return color(red, green, blue);
    } else if (this.temperature < 800) { // COLD GRAY  
      return rockGray;
    } else if (this.temperature < 1000) { // COLD GRAY  
      float prog = (this.temperature - 800)/200;
      int red = (int)red(rockGray) + round((red(orange)-red(rockGray))*prog);
      int green = (int)green(rockGray) + round((green(orange)-green(rockGray))*prog);
      int blue = (int)blue(rockGray) + round((green(orange)-blue(rockGray))*prog);
      return color(red, green, blue);
    } else { // fully white at 6000K
      float whiteProg = min((this.temperature - 1000)/5000,1);
      int red = (int)red(orange) + round((255-red(orange))*whiteProg);
      int green = (int)green(orange) + round((200-green(orange))*whiteProg);
      int blue = (int)blue(orange) + round((20-blue(orange))*whiteProg);
      return color(red, green, blue);
    }
  }
  
  void display(PVector origin) {
    noStroke();
    
    ellipseMode(CENTER);
    
    PVector drawCenter = PVector.add(origin, this.position);
    
    float drawSize = this.diameter + this.diameter * zoomFactor * sin(this.orbit);
    
    float drawWidth = drawSize;
    float drawHeight = drawSize;
    
    if (this.temperature > 800) {
      float glowProg = min((this.temperature - 1000)/6000,1);
      fill(color(255, 0, 0, round((glowProg)*255)));
      ellipse(drawCenter.x, drawCenter.y, drawWidth*1.1, drawHeight*1.1);
    }
    
    fill(this.getColor());
    ellipse(drawCenter.x, drawCenter.y, drawWidth, drawHeight);
  }
  
  void orbit() {
    this.orbit = (this.orbit + dt)%(2*PI);
    PVector newPos = new PVector(-orbitRadius*cos(this.orbit), orbitRadius*sin(this.orbit)*eccentricity);
    this.position = PVector.add(newPos, this.origin);
  }
}
