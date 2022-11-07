class BlueBoid extends Boid{
    public String type;
    float maxspeed;

    BlueBoid(float x, float y, String type) {
        super(x, y);
        this.type = type;
        maxspeed = 2.0;
    }

    public String toString() {
        return this.type;
    }


    // We accumulate a new acceleration each time based on three rules
    void flock(ArrayList<Boid> boids) {
        PVector sep = this.separate(boids);   // Separation
        PVector ali = this.align(boids);      // Alignment
        PVector coh = this.cohesion(boids);   // Cohesion
        PVector hun = this.hunt(boids);       // Hunt
        PVector fle = this.flee(boids);       // Flee
        // Arbitrarily weight these forces
        sep.mult(1);
        ali.mult(1);
        coh.mult(1);
        hun.mult(1);
        fle.mult(1);
        // Add the force vectors to acceleration
        applyForce(sep);
        applyForce(ali);
        applyForce(coh);
        applyForce(hun);
        applyForce(fle);
    }



    void render() {
        if (!this.dead){
            // Draw a triangle rotated in the direction of velocity
            float theta = velocity.heading() + radians(90);

            fill(0, 0, 128, 60);
            stroke(0, 0, 128);
            pushMatrix();
            translate(position.x, position.y);
            rotate(theta);
            beginShape(TRIANGLES);
            vertex(0, -r*6);
            vertex(-r*2, r*6);
            vertex(r*2, r*6);
            endShape();
            popMatrix();
        }
    }

    // Separation
    // Method checks for nearby boids and steers away
    PVector separate (ArrayList<Boid> boids) {
        float desiredseparation = 25.0f;
        PVector steer = new PVector(0, 0, 0);
        int count = 0;
        // For every boid in the system, check if it's too close
        for (Boid other : boids) {
            float d = PVector.dist(position, other.position);
            // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
            if ((d > 0) && (d < desiredseparation)) {
                // Calculate vector pointing away from neighbor
                PVector diff = PVector.sub(position, other.position);
                diff.normalize();
                diff.div(d);        // Weight by distance
                steer.add(diff);
                count++;            // Keep track of how many
            }
        }
        // Average -- divide by how many
        if (count > 0) {
            steer.div((float)count);
        }

        // As long as the vector is greater than 0
        if (steer.mag() > 0) {
            // First two lines of code below could be condensed with new PVector setMag() method
            // Not using this method until Processing.js catches up
            // steer.setMag(maxspeed);

            // Implement Reynolds: Steering = Desired - Velocity
            steer.normalize();
            steer.mult(maxspeed);
            steer.sub(velocity);
            steer.limit(maxforce);
        }
        return steer;
    }

    // Alignment
    // For every nearby boid in the system, calculate the average velocity
    PVector align (ArrayList<Boid> boids) {
        float neighbordist = 50;
        PVector sum = new PVector(0, 0);
        int count = 0;
        for (Boid other : boids) {
            float d = PVector.dist(position, other.position);
            if ((d > 0) && (d < neighbordist)) {
                sum.add(other.velocity);
                count++;
            }
        }
        if (count > 0) {
            sum.div((float)count);
            // First two lines of code below could be condensed with new PVector setMag() method
            // Not using this method until Processing.js catches up
            // sum.setMag(maxspeed);

            // Implement Reynolds: Steering = Desired - Velocity
            sum.normalize();
            sum.mult(maxspeed);
            PVector steer = PVector.sub(sum, velocity);
            steer.limit(maxforce);
            return steer;
        } 
        else {
            return new PVector(0, 0);
        }
    }

    // Cohesion
    // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
    PVector cohesion (ArrayList<Boid> boids) {
        float neighbordist = 50;
        PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
        int count = 0;
        for (Boid other : boids) {
            float d = PVector.dist(position, other.position);
            if ((d > 0) && (d < neighbordist)) {
                sum.add(other.position); // Add position
                count++;
        }
        }
        if (count > 0) {
            sum.div(count);
            return seek(sum);  // Steer towards the position
        } 
        else {
            return new PVector(0, 0);
        }
    }

    // Hunt
    // Seeks the nearest available prey
    PVector hunt (ArrayList<Boid> boids) {
        PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
        float min_d = 3000.0;
        Boid prey = null;

        for (Boid other : boids) {
            if (other.toString().equals("Green")){
                float d = PVector.dist(this.position, other.position);
                if (d < 4) {
                    other.die();
                } else if (d < min_d || prey == null) {
                    min_d = d;
                    prey = other;
                }
            }
        }

        sum.add(prey.position);
        return seek(sum);
    }

    // Flee
    // Runs from predators
    PVector flee (ArrayList<Boid> boids) {
        float desiredseparation = 150.0f;
        PVector steer = new PVector(0, 0, 0);
        int count = 0;
        // For every predator boid in the system, check if it's too close
        for (Boid other : boids) {
            if (other.toString().equals("Red")){
                float d = PVector.dist(position, other.position);
                // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
                if ((d > 0) && (d < desiredseparation)) {
                    // Calculate vector pointing away from neighbor
                    PVector diff = PVector.sub(position, other.position);
                    diff.normalize();
                    diff.div(d);        // Weight by distance
                    steer.add(diff);
                    count++;            // Keep track of how many
                }
            }
        }
        // Average -- divide by how many
        if (count > 0) {
            steer.div((float)count);
        }

        // As long as the vector is greater than 0
        if (steer.mag() > 0) {
            // First two lines of code below could be condensed with new PVector setMag() method
            // Not using this method until Processing.js catches up
            // steer.setMag(maxspeed);

            // Implement Reynolds: Steering = Desired - Velocity
            steer.normalize();
            steer.mult(maxspeed);
            steer.sub(velocity);
            steer.limit(maxforce);
        }
        return steer;
    }
}
