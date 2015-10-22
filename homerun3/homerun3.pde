import oscP5.*;
import netP5.*;

final int N_CHANNELS = 4;
final int BUFFER_SIZE = 30;
float[][] buffer = new float[N_CHANNELS][BUFFER_SIZE];
int pointer = 0;
final int PORT = 5000;
OscP5 oscP5 = new OscP5(this, PORT);

final color BG_COLOR = color(0, 0, 0);
final color BALL_COLOR = color(255, 255, 255);
final color BAT_COLOR = color(204,102,0);

final int size_x=1000;
final int size_y=600;
final int ball_max=10;
int ball_n;
Ball ball = new Ball();
PImage btg;
PImage[] pitcher;
Batter bat = new Batter();
int time;
int difficulty; // 0: easy, 1: difficult

Configuration configuration;

void setup(){
  size(size_x,size_y);
  smooth();
  fill(255,255,255);
  textSize(50);
  btg = loadImage("bat.jpg");
  configuration = new Configuration();
  pitcher = new PImage[11];
  reset();
  for(int i=1;i<=pitcher.length;i++){
    pitcher[i-1]=loadImage("sawa"+i+".jpg");
  }
}

void reset() {
  background(BG_COLOR);
  ball_n=0;
  bat.homerun_n=0;
  bat.getPoint=0;
  time=-180;
  ball.ballSet();
  difficulty = 0;
}

void draw(){
  switch(configuration.getScreen()) {
    case Configuration.MENU:
      loopMenu();
      break;
    case Configuration.GAME:
      loopGame();
      break;
    case Configuration.RESULT:
      loadResult();
      break;
  }
}

void keyPressed() {
  switch(configuration.getScreen()) {
    case Configuration.MENU:
      if (keyCode == DOWN) {
        difficulty = (difficulty+1) % 2;
      }
      if (keyCode == UP) {
        // FIXME: とりま二段階なのでぷらす
        difficulty = (difficulty+1) % 2;
      }
      break;
  }
}

void loopMenu() {
  background(BG_COLOR);
  text("CHOOSE DIFFICULTY",10,50);
  text("AND PRESS SPACE KEY TO START",10,100);
  if(difficulty == 0) {
    text(">EASY<",10,400);
    text("DIFFICULT",10,500);
  }
  if(difficulty == 1) {
    text("EASY",10,400);
    text(">DIFFICULT<",10,500);
  }
  if(key == ' ') {
    configuration.setScreen(Configuration.GAME);
  }
}

void loopGame() {
  time+=1;
  float alpha=alphaCalc();
  bat.preSet(btg,alpha);
  if(ball_n>=ball_max){
    configuration.setScreen(Configuration.RESULT);
  }else if(time>=180){
    time=0;
    ball_n+=1;
    ball.ballSet();
  }
  if(time<=60){
    background(BG_COLOR);
    if(time<0){
      image(pitcher[0],490,160,80,110);
      fill(255,255,255);
      textSize(100);
      text(int(time*(-1)/60+1),450,350);
    }else if(time>=0){
      image(pitcher[time/6],490,160,80,110);
    }
    bat.batSet();
  }
  if(time>=61&&!ball.hit){
    background(BG_COLOR);
    image(pitcher[10],490,160,80,110);
    ball.ballThrow();
    if(bat.swing){
      ball.hitted(time,bat,alpha);
      bat.swing();
    }else{
      bat.batSet();
    }
    if(mousePressed&&!bat.swing){
      bat.swing=true;
      bat.swing();
    }
  }
  if(ball.hit){
    background(BG_COLOR);
    image(pitcher[10],490,160,80,110);
    ball.ballFly();
    if(ball.homerun&&ball.s<=5){
      fill(255,255,255);
      textSize(100);
      text("HOMERUN",size_x*0.25,size_y*0.4);
      textSize(50);
      text("distance:"+ball.dis,size_x*0.3,size_y*0.6);
      }
    bat.swing();
  }
}

void loadResult() {
  text("finish",size_x*0.43,size_y*0.4);
  text(bat.homerun_n + " HOMERUN",size_x*0.35,size_y*0.6);
  text("POINTS: " + bat.getPoint,size_x*0.35,size_y*0.8);
  if(mousePressed){
    mousePressed = false;
    reset();
    configuration.setScreen(Configuration.MENU);
  }
}

void oscEvent(OscMessage msg){
  float data;
  if(msg.checkAddrPattern("/muse/elements/alpha_relative")){
    for(int ch=0;ch<N_CHANNELS;ch++){
      data = msg.get(ch).floatValue();
      buffer[ch][pointer] = data;
    }
    pointer = (pointer+1) % BUFFER_SIZE;
  }
}

float alphaCalc(){
  float alphaSum=0;
  for(int i=0;i<N_CHANNELS;i++){
    for(int j=0;j<BUFFER_SIZE;j++){
      alphaSum+=buffer[i][j];
    }
  }
  return alphaSum/(N_CHANNELS*BUFFER_SIZE);
}


class Batter{
  int l;
  int w;
  int x;
  int y;
  int t;
  boolean swing;
  int homerun_n;
  int getPoint;
  PImage btg;
  float alpha;

  void batSet(){
    l=150;
    w=200;
    x=(size_x-l)/2;
    y=size_y-50;
    t=0;
    swing=false;
    fill(BAT_COLOR);
    translate(x,y);
    rotate(7*PI/6);
    image(btg,0,0,l,w*0.1);//w*alpha
    resetMatrix();
  }

  void swing(){
    t+=1;
    fill(BAT_COLOR);
    translate(x,y);
    if(t==1){
      rotate(7*PI/6);
      l=60;
    }else if(t<=6){
      rotate((4-t)*PI/12);
      l=150-(4-t)^2*15;
    }else if(t==7){
      rotate(5*PI/3);
      l=70;
    }else if(t==8){
      rotate(4*PI/3);
      l=100;
    }else{
      rotate(13*PI/12);
      l=130;
    }
    image(btg,0,0,l,w*0.1);//w*alpha
    resetMatrix();
  }

  void preSet(PImage btgg, float alphaa){
    btg=btgg;
    alpha=alphaa;
  }

}

class Ball{
  int x;
  int y;
  float s;
  int v;
  int dir;
  int dis;
  boolean hit;
  boolean homerun;

  void ballSet(){
    x=(size_x)/2;
    y=size_y-400;
    s=5;
    v=1;
    dir=-3;
    hit=false;
    homerun=false;
  }

  void ballThrow(){
    y+=v;
    v+=1;
    s+=0.7;
    fill(BALL_COLOR);
    ellipse(x,y,s,s);
  }

  void hitted(int time, Batter bat,float alpha){
    int t=bat.t;
    if(90<=time+t&&time+t<=91&&2<=t&&t<=6){
      hit=true;
        dis = int(100*random(0.5,1.5));
//      dis = int(60+alpha*300);
      if(t==6){
        dir=-2;
        v=28;
      }else if(t==5){
        dir=-1;
        v=31;
      }else if(t==4){
        dir=0;
        v=32;
      }else if(t==3){
        dir=1;
        v=33;
      }else{
        dir=2;
        v=33;
      }
      if(3<=t&&t<=5){
        if(t==4){
          if(dis>=120){
            bat.homerun_n+=1;
            homerun=true;
            bat.getPoint+=dis*2;
          }else{
            bat.getPoint+=dis*0.2;
          }
        }else{
          if(dis>=100){
            bat.homerun_n+=1;
            homerun=true;
            bat.getPoint+=dis;
          }else{
            bat.getPoint+=dis*0.1;
          }
        }
      }
    }
  }

  void ballFly() {
    if(dir==-2){
      x-=13;
    }else if(dir==-1){
      x-=5;
    }else if(dir==1){
      x+=5;
    }else if(dir==2){
      x+=13;
    }
    y-=v;
    v-=1;
    if(s>0){
      s-=0.45;
    }
    fill(BALL_COLOR);
    ellipse(x,y,s,s);
  }
}


class Configuration {
  private int screen;
  public static final int MENU = 0;
  public static final int GAME = 1;
  public static final int RESULT = 2;
  public Configuration() {
    screen = MENU;
  }
  public int getScreen() {
    return screen;
  }
  public void setScreen(int screen) {
    this.screen = screen;
  }
}
