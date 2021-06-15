float speedMultiplier = 10;
float semiMajorAxis = 400;
float semiMinorAxis = 300;
int amountOfLinesDrawn;

PVector[] impactPoints = { };
PVector ellipseCenter;
PVector rayPosition;
PVector rayHeading;

void setup() {
  size(900, 900, P2D);
  // fullScreen(P2D);
  textSize(16);
  frameRate(144);
  smooth();
  noStroke();
  strokeWeight(0);
  background(0);

  lastIncidentAngle = 0;
  lastReflectedAngle = 0;
  ellipseCenter = new PVector(width / 2, height / 2);
  rayPosition = new PVector(0, 0);
  rayHeading = new PVector(1, 1);
  impactPoints = new PVector[] { };

  rayHeading.normalize();
}

/**
 * Returns whether or not the given point has passed outside of the ellipse.
 */
boolean hasCollided(PVector pointToCheck) {
  return pow(pointToCheck.x / semiMajorAxis, 2) + 
         pow(pointToCheck.y / semiMinorAxis, 2) >= 1;
}

/**
 * Gets the point of impact with the ellipse.
 */
PVector getPointOfImpact(PVector pointToCheck) {
  float mathThingy = semiMajorAxis * semiMinorAxis / sqrt(pow(semiMajorAxis, 2) * pow(pointToCheck.y, 2) + pow(semiMinorAxis, 2) * pow(pointToCheck.x, 2));
  return new PVector(
    mathThingy * pointToCheck.x,
    mathThingy * pointToCheck.y
  );
}

float lastIncidentAngle;
float lastReflectedAngle;
PVector getReflectionVector() {
  PVector pointOfImpact = getPointOfImpact(rayPosition);
  PVector normalToEllipse = getNormalToEllipseByPoint(pointOfImpact);
  PVector reflectionVector = mirrorVectorByNormal(rayHeading, normalToEllipse);

  lastIncidentAngle = (PVector.angleBetween(normalToEllipse, rayHeading) * 180 / PI);
  lastReflectedAngle = 180 - (PVector.angleBetween(normalToEllipse, reflectionVector) * 180 / PI);

  return reflectionVector;
}

PVector getNormalToEllipseByPoint(PVector point) {
  float x = semiMinorAxis * point.x / semiMajorAxis;
  float y = semiMajorAxis * point.y / semiMinorAxis;
  PVector normalVector = new PVector(x, y);
  normalVector.normalize();

  return normalVector;
}

PVector mirrorVectorByNormal(PVector incidentVector, PVector normalVector) {
  float velocityDotProduct = PVector.dot(normalVector, incidentVector);
  PVector reflectedVector = new PVector(incidentVector.x - 2 * velocityDotProduct * normalVector.x, incidentVector.y - 2 * velocityDotProduct * normalVector.y);
  
  return reflectedVector;
}

String textToDisplay = "";
void draw() {
  background(0);
  drawRay();
  drawText();
  drawEllipse();

  text(textToDisplay, 5, 48);

  if (hasCollided(new PVector(rayPosition.x, rayPosition.y))) {
    // PVector pointOfImpact = getPointOfImpact(rayPosition);
    // stroke(255, 0, 0);
    // text("pointOfImpact: (" + pointOfImpact.x + ", " + pointOfImpact.y + ")", 5, 32);
    // line(rayPosition.x + ellipseCenter.x, rayPosition.y + ellipseCenter.y, pointOfImpact.x + ellipseCenter.x, pointOfImpact.y + ellipseCenter.y);
    // fill(255, 255, 255);
    PVector pointOfImpact = getPointOfImpact(rayPosition);
    impactPoints = (PVector[])append(impactPoints, new PVector(pointOfImpact.x, pointOfImpact.y));
    amountOfLinesDrawn = impactPoints.length;
    // rayHeading = getReflectionVector(rayPosition);
    fill(255, 255, 255);
    PVector vector = getReflectionVector();
    vector.normalize();
    textToDisplay = "(" + nf(rayHeading.x, 0, 2) + " " + nf(rayHeading.y, 0, 2) + ") |" + nf(rayHeading.mag(), 0, 2) + "|";
    rayHeading.set(vector.x, vector.y);
  }

  moveRay();
}

void drawEllipse() {
  fill(255, 255, 255);
  stroke(255, 255, 255);
  float ellipseWidth = 2;
  strokeWeight(ellipseWidth);

  PVector[] pointsInEllipse = { };

  float t = 0;
  while (t <= 2 * PI) {
    float x = semiMajorAxis * cos(t);
    float y = semiMinorAxis * sin(t);
    PVector ellipseDotPosition = new PVector(x, y);
    ellipseDotPosition.add(ellipseCenter);
    pointsInEllipse = (PVector[])append(pointsInEllipse, ellipseDotPosition);

    t += 0.1;
  }

  for (int i = 0; i < pointsInEllipse.length; ++i) {
    if (i > 0) {
      line(pointsInEllipse[i].x, pointsInEllipse[i].y, pointsInEllipse[i - 1].x, pointsInEllipse[i - 1].y);
    } else {
      line(pointsInEllipse[i].x, pointsInEllipse[i].y, pointsInEllipse[pointsInEllipse.length - 1].x, pointsInEllipse[pointsInEllipse.length - 1].y);
    }
  }

  float fociDistanceToCenter = sqrt(pow(semiMajorAxis, 2) - pow(semiMinorAxis, 2));
  circle(ellipseCenter.x - fociDistanceToCenter, ellipseCenter.y, ellipseWidth);
  circle(ellipseCenter.x + fociDistanceToCenter, ellipseCenter.y, ellipseWidth);

  if (mousePressed) {
    strokeWeight(1);
    stroke(0, 255, 255);
    line(rayPosition.x + ellipseCenter.x, rayPosition.y + ellipseCenter.y, mouseX, mouseY);
    noStroke();
  }
}

void drawRay() {
  // fill(255, 0, 0, 100);
  // circle(rayPosition.x + ellipseCenter.x, rayPosition.y + ellipseCenter.y, 3);

  strokeWeight(2);
  stroke(0, 255, 0, 50);

  for (int i = 0; i < impactPoints.length; ++i) {
    // text(i + "\t(" + impactPoints[i].x + ", " + impactPoints[i].y + ")", 5, 120 + (i*15));
    if (i > 0) {
      line(impactPoints[i].x + ellipseCenter.x, impactPoints[i].y + ellipseCenter.y, impactPoints[i - 1].x + ellipseCenter.x, impactPoints[i - 1].y + ellipseCenter.y);
    }

    if (i == impactPoints.length - 1) {
      line(impactPoints[i].x + ellipseCenter.x, impactPoints[i].y + ellipseCenter.y, rayPosition.x + ellipseCenter.x, rayPosition.y + ellipseCenter.y);
    }
  }

  noStroke();
}

void moveRay() {
  rayPosition.add(rayHeading.x * speedMultiplier, rayHeading.y * speedMultiplier);
}

void drawText() {
  int fps = (int)frameRate;
  if (fps > 60) {
    fill(0, 255, 0);
  } else if (fps > 30) {
    fill(255, 255, 0);
  } else {
    fill(255, 0, 0);
  }

  text(int(frameRate) + " FPS", 5, 16);
  fill(255, 255, 255);

  text(amountOfLinesDrawn + " lines", 5, 32);

  if (max(lastIncidentAngle, lastReflectedAngle) - min(lastIncidentAngle, lastReflectedAngle) <= 0.0001)
    fill(0, 255, 0);
  else
    fill(255, 0, 0);

  text("θ₀ " + nf(lastIncidentAngle, 0, 2) + "º", 5, 64);
  text("θ₁ " + nf(lastReflectedAngle, 0, 2) + "º", 5, 80);
}

void mousePressed() {
  setup();
  rayPosition = new PVector(mouseX - ellipseCenter.x, mouseY - ellipseCenter.y);
  rayHeading.set(0, 0);
}

void mouseReleased() {
  // rayHeading = new PVector(mouseX - rayPosition.x, mouseY - rayPosition.y).normalize();
  rayHeading = new PVector(mouseX - (rayPosition.x + ellipseCenter.x), mouseY - (rayPosition.y + ellipseCenter.y)).normalize();
  // isPositioning = false;
}

void keyPressed() {
  if(key == 32) {
    setup();
  }
}
