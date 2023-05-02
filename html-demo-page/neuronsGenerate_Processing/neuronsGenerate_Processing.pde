import hypermedia.net.*;
import java.util.List;
import culebra.objects.*;
import culebra.viz.*;
import culebra.data.*;

import toxi.geom.*;
import toxi.color.*;

UDP udp;  // define the UDP object
Creeper creep;
List<Creeper> creeperSet;
PVector loc;
PVector vel;
// ---------------------Behavior Flags-----------------
boolean createTrails = true;
boolean cohFlag = false;
boolean sepFlag = true;
boolean aligFlag = false;
boolean flockFlag = false;
boolean wanderFlag = true;
boolean drawConn = true;
// --------------------OcTree + QTree------------------
QuadTree qtree;
boolean createQTree = false;
boolean showQTree = false;
// -------------------Spawn Stuff----------------------
boolean spawnEdge = false;
// --------------------Path Stuff--------------------
Path tempPath;
ArrayList<Path> pathList;
int pathCount = 10;
boolean drawPaths = false;
float scalarProjectionDist;
float pathRadius = 25.0f;
List<ArrayList<PVector>> cummPathPts;
// -------------------Environ Stuff--------------------
int creepCount = 500;
PImage img0, img1, img2;
boolean showMap = false;
// -------------------Children Stuff--------------------
boolean triggerBabies;
ArrayList<PVector> childSpawners;
ArrayList childSpawnType;



ArrayList<newComPoint> ptAll=new ArrayList<newComPoint>();
ArrayList<PVector> stablePt=new ArrayList<PVector>();


// -----------------------Setup-----------------------
public void setup() {
  size(1400, 800, FX2D);
  udp = new UDP( this, 8001);
  udp.listen( true );
  smooth();
  background(0);

  this.img0 = loadImage("LULZ.png");
  this.img1 = loadImage("map_C.jpg");
  this.img2 = loadImage("SI.png");

  this.childSpawners = new ArrayList<PVector>();
  this.childSpawnType = new ArrayList();
  this.cummPathPts = new ArrayList<ArrayList<PVector>>();

  this.creeperSet = new ArrayList<Creeper>();
  scalarProjectionDist = 50.0f;
  pathList = new ArrayList<Path>();

  //for (int pth = 0; pth < this.pathCount; pth++) {
  //  newPath();
  //}

  for (int i = 0; i < creepCount; i++) {
    if (this.spawnEdge) {
      this.loc = new PVector(0, random(height), 0);
      this.vel = new PVector(1, 0, 0);
    } else {
      this.loc = new PVector(random(0, width), random(0, height), 0);
      this.vel = new PVector(random(-1.5f, 1.5f), random(-1.5f, 1.5f), 0);
    }
    this.creep = new Creeper(loc, vel, true, false, this);
    this.creeperSet.add(this.creep);
  }
}
// -----------------------Draw-----------------------
public void draw() {
  //background(0);
  fill(0,10);
  rect(0,0,width,height);
  // -----------------------PATH STUFF-----------------------
  if (this.pathList != null) {
    for (Path pths : pathList) {
      pths.setPathRadius(pathRadius);
      if (drawPaths) {

        stroke(175, 0, 0, 50);
        strokeWeight(pths.getPathRadius() * 2);
        noFill();
        beginShape();
        for (PVector v : pths.getPathPoints()) {
          vertex(v.x, v.y);
        }
        endShape();

        // Draw thin line for center of path
        stroke(255);
        strokeWeight(1);
        noFill();
        beginShape();
        for (PVector v : pths.getPathPoints()) {
          vertex(v.x, v.y);
        }
        endShape();
      }
    }
  }
  for (Creeper c : this.creeperSet) {
    c.setMoveAttributes(2.0f, 0.2f, 1.5f);
    if (c.behavior.isSeparateActive() && c.behavior.isInstanceable() && this.sepFlag) {
      c.behavior.creeperSeparate(5.0f, creeperSet);
    }
    c.behavior.multiShapeTrackerMapBabyMaker(this.cummPathPts, 1000, 50, pathRadius, triggerBabies, 2, true, this.childSpawners, this.childSpawnType, this.img1, true, true, false, 0.1f, 1.0f);
    this.childSpawners = c.behavior.getChildStartPositions();
    this.childSpawnType = c.behavior.getChildSpawnType();    

    if (this.aligFlag) {
      c.behavior.creeperAlign(30.0f, 0.045f, creeperSet);
    }
    if (this.cohFlag) {
      c.behavior.creeperCohesion(30.0f, 0.045f, creeperSet);
    }
    if (this.wanderFlag) {
      float change = 100;
      //c.behavior.wander2D(true, false, change, 60.0f, 60.0f);
      c.behavior.superWander2D(change, 10.0f, 20.0f, 6.0f);
    }
    if (this.flockFlag) {
      if (this.createQTree) {
        c.behavior.creeperflock2DTree(80.0f, 0.2f, 0.09f, 0.045f, creeperSet, Data.getQuadtree(), Data.getQTNodes(), this.drawConn);
      } else {
        c.behavior.creeperflock2D(30.0f, 0.14f, 0.09f, 0.045f, creeperSet, this.drawConn);
      }
    }      
    c.bounce(width, height);
    c.move(0, 1000);
    if (createTrails) {
      if (!(c instanceof BabyCreeper)) {  
        // --------Draw trails with color and with gradient--------
        float colorA[] = new float[] { 1f, 0f, 0f };
        float colorB[] = new float[] { 0.73f, 0.84f, 0.15f };
        c.viz.drawGradientTrailsFX(c.getTrailPoints(), 1000, colorA, colorB, 255.0f, 1.0f);
      } else if (c instanceof BabyCreeper) {
        if (((BabyCreeper)c).getType() == "a") {
          float colorA[] = new float[] { 120.0f, 0.0f, 0.0f };
          float colorB[] = new float[] { 0.0f, 255.0f, 255.0f };
          c.viz.drawGradientTrailsFX(c.getTrailPoints(), 1000, colorA, colorB, 255.0f, 1.0f);
        } else {
          float colorA[] = new float[] { 255.0f, 0.0f, 120.0f };
          float colorB[] = new float[] { 200.0f / 60.0f, 160.0f / 100.0f, 80.0f / 30.0f };
          c.viz.drawGradientTrailsFX(c.getTrailPoints(), 1000, colorA, colorB, 255.0f, 1.0f);
        }
      }
    }  
    pushStyle();
    stroke(255);
    strokeWeight(4);
    ellipse(c.getLocation().x, c.getLocation().y, 2, 2);
    popStyle();

    if (this.showMap) {
      image(img1, 0, 0);
      tint(255, 120);
    }
  }

  if (this.childSpawners.size() > 0) {
    newDude();
    this.childSpawners = new ArrayList<PVector>();
    this.childSpawnType = new ArrayList();
  }  
  surface.setSize(width, height);
}
// ---------------------------------------Children Creation-----------------------------------
void newDude() {
  int babyCount = 0;
  for (PVector px : this.childSpawners) {
    PVector speed;
    if (this.spawnEdge) {
      speed = new PVector(1, 0, 0);
    } else {
      speed = new PVector(random(-1, 1), random(-1, 1), 0);
    }
    Creeper a;
    if ((int) this.childSpawnType.get(babyCount) % 2 == 0) {
      a = new BabyCreeper(new PVector(px.x, px.y, px.z), speed, false, "a", false, this);
      this.creeperSet.add(a);
    } else {
      a = new BabyCreeper(new PVector(px.x, px.y, px.z), speed, false, "b", false, this);
      this.creeperSet.add(a);
    }
    babyCount++;
  }
}
// ------------------------Create Paths----------------------------------
public void keyPressed() {
  if (key == 'R')
    setup();
  if (key == 'T')this.createTrails = !this.createTrails;
  if (key == 'D')drawPaths = !drawPaths;
  if (key == 'C')this.cohFlag = !this.cohFlag;
  if (key == 'A')this.aligFlag = !this.aligFlag;
  if (key == 'S')this.sepFlag = !this.sepFlag;
  if (key == 'F')this.flockFlag = !this.flockFlag;
  if (key == 'W')this.wanderFlag = !this.wanderFlag;  
  if (key == '1')this.drawConn = !this.drawConn;
  if (key == 'B') this.triggerBabies = !this.triggerBabies;
  if  (key == 'E') this.spawnEdge = !this.spawnEdge;
  if (key == 'M') this.showMap = !this.showMap;  
}
// ---------------------------------------Create
// StaticPaths---------------------------------
void newPath() {
  ArrayList<PVector>pathPtList = new ArrayList<PVector>();
  this.tempPath = new Path();
  this.tempPath.addPoint(random(30, 300), random(height / 4, height), 0);
  this.tempPath.addPoint(random(101, width / 2), random(0, height), 0);
  this.tempPath.addPoint(random(width / 2, width), random(0, height), 0);
  this.tempPath.addPoint(random(width - 100, width), height / 2, 0);
  pathPtList.addAll(this.tempPath.getPathPoints());
  this.cummPathPts.add(pathPtList);
  this.pathList.add(this.tempPath);
}
