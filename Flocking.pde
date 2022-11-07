Flock flock;

void setup() {
  int w = 1920;
  int h = 1040;
  size(1920, 1040);
  flock = new Flock();
  // Add an initial set of boids into the system
  for (int i = 0; i < 450; i++) {
    if (i % 3 == 0)
      flock.addBoid(new RedBoid(int(random(w)), int(random(h)), "Red"));
    else if (i % 3 == 1)
      flock.addBoid(new BlueBoid(int(random(w)), int(random(h)),"Blue"));
    else 
      flock.addBoid(new GreenBoid(int(random(w)), int(random(h)), "Green"));
  }
}

void draw() {
  background(200);
  flock.run();
}

// Add a new boid into the System
void mousePressed() {
  setup();
}
