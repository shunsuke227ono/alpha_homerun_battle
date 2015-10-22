import oscP5.*;
import netP5.*;

final int N_CHANNELS = 4;
final int BUFFER_SIZE = 30;
float[][] buffer = new float[N_CHANNELS][BUFFER_SIZE];
int pointer = 0;
final int PORT = 5000;
OscP5 oscP5 = new OscP5(this, PORT);

final color BG_COLOR = color(0,0,0);
final color TX_COLOR = color(255,255,0);
final color BALL_COLOR = color(255,255,255);
final color BAT_COLOR = color(204,102,0);

final int size_x=960;
//final int size_y=556;
final int size_y=700;
final float ball_sy=425;
final float pit_Dis=140;
final int ball_max=10;
int ball_n;
Ball ball = new Ball(ball_sy,pit_Dis);
PImage btg;
PImage[] pitcher;
PImage ground;
Batter bat = new Batter(ball_sy,pit_Dis);
int time;
int difficulty; // 0: easy, 1: difficult

Configuration configuration;

void setup(){
  fill(TX_COLOR);
  textAlign(CENTER);
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
  ground = loadImage("jingu.jpg");
  bgSet();
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
  if (mousePressed) {
    background(BG_COLOR);
    configuration.setScreen(Configuration.RESULT);
  }
}

void loopMenu() {
  background(BG_COLOR);
  text("CHOOSE DIFFICULTY", size_x*0.5, 50);
  text("AND PRESS SPACE KEY TO START", size_x*0.5, 100);
  if(difficulty == 0) {
    text(">EASY<", size_x*0.5, 400);
    text("DIFFICULT",size_x*0.5, 500);
  }
  if(difficulty == 1) {
    text("EASY",size_x*0.5,400);
    text(">DIFFICULT<",size_x*0.5,500);
  }
  if(key == ' ') {
    configuration.setScreen(Configuration.GAME);
  }
}

void loopGame() {
  time++;
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
  bgSet();
    if(time<0){
      fill(TX_COLOR);
      textAlign(CENTER,BOTTOM);
      textSize(100);
      text(int(time*(-1)/60+1),size_x*0.5,size_y*0.5);
    }else if(time>=0){
      pitSet(time/6);
      bat.batSet();
    }
  }
  if(time>=61&&!ball.hit){
    bgSet();
    pitSet(10);
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
    if(ball.y>=size_y+100){
      fill(TX_COLOR);
      textAlign(CENTER);
      textSize(100);
      text("STRIKE",size_x*0.5,size_y*0.4);
    }
  }
  if(ball.hit){
    bgSet();
    pitSet(10);
    ball.ballFly();
    if(ball.s<=5){
      fill(TX_COLOR);
      textAlign(CENTER);
      textSize(100);
      if(ball.homerun){
        text("HOME-RUN!!",size_x*0.5,size_y*0.4);
        textSize(50);
        text("distance:"+ball.dis,size_x*0.5,size_y*0.6);
      }else if(ball.single){
        text("HIT!",size_x*0.5,size_y*0.4);
      }else{
        text("FOUL",size_x*0.5,size_y*0.4);
      }
    }
    bat.swing();
  }
}

void loadResult() {
  fill(TX_COLOR);
  textSize(100);
  text("finish",size_x*0.5,size_y*0.4);
  text(bat.homerun_n + " HOMERUN",size_x*0.5,size_y*0.6);
  text("POINTS: " + bat.getPoint,size_x*0.5,size_y*0.8);
  if(mousePressed){
    reset();
    configuration.setScreen(Configuration.MENU);
    mousePressed = false;
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

void pitSet(int i){
  image(pitcher[i],size_x*0.5-8,ball_sy-10,64,88);
}

void bgSet(){
  image(ground,0,0,size_x,size_y);
}

class Batter{
  float l;
  float w;
  float x;
  float y;
  int t;
  boolean swing;
  int homerun_n;
  int getPoint;
  PImage btg;
  float alpha;
  final int LENGTH=100;
  float ball_sy;
  float pit_Dis;

  Batter(float le, float dis){
    ball_sy=le;
    pit_Dis=dis;
  }

  void batSet(){
    l=LENGTH;
    w=100;
    x=(size_x-l)/2;
    y=ball_sy+pit_Dis;
    t=0;
    swing=false;
    fill(BAT_COLOR);
    translate(x,y);
    rotate(7*PI/6);
    float wid;
    if(alpha==0){
      wid=w*0.1;
    }else{
      if(alpha<0.03){
        alpha=0.03;
      }
      wid=w*alpha;
    }
    image(btg,0,0,l,wid);
    resetMatrix();
  }

  void swing(){
    if(t<=8){
      t++;
    }
    fill(BAT_COLOR);
    translate(x,y);
    if(t==1){
      rotate(7*PI/6);
      l=LENGTH*0.4;
    }else if(t<=6){
      rotate((4-t)*PI/12);
      l=LENGTH-(4-t)^2*LENGTH/6;
    }else if(t==7){
      rotate(5*PI/3);
      l=LENGTH*0.4;
    }else if(t==8){
      rotate(4*PI/3);
      l=LENGTH*0.7;
    }else{
      rotate(13*PI/12);
      l=LENGTH;
    }
    float wid;
    if(alpha==0){
      wid=w*0.1;
    }else{
      if(alpha<0.03){
        alpha=0.03;
      }
      wid=w*alpha;
    }
    image(btg,0,0,l,wid);
    resetMatrix();
  }

  void preSet(PImage btgg, float alphaa){
    btg=btgg;
    alpha=alphaa;
  }

}

class Ball{
  float x;
  float y;
  float s;
  float ss;
  float v;
  float vv;
  int dir;
  int dis;
  boolean hit;
  boolean homerun;
  boolean single;
  float ball_sy;
  float pit_Dis;

  Ball(float le, float dis){
    ball_sy=le;
    pit_Dis=dis;
  }

  void ballSet(){
    x=(size_x)/2;
    y=ball_sy;
    s=2;
    ss=0.1;
    v=0;
    vv=0;
    dir=-3;
    hit=false;
    homerun=false;
    single=false;
  }

  void ballThrow(){
    y+=v;
    v+=vv;
    vv+=pit_Dis*6/(24*25*26);
    s+=ss;
    ss+=0.05;
    fill(BALL_COLOR);
    ellipse(x,y,s,s);
  }

  void hitted(int time, Batter bat,float alpha){
    int t=bat.t;
    if(90<=time+t&&time+t<=91&&2<=t&&t<=6){
      hit=true;
      float alp;
      if(alpha==0){
        alp=0.1;
      }else{
        if(alpha<0.03){
          alpha=0.03;
        }
        alp=alpha;
      }
      dis = int((50+alpha*500)*random(0.5,1.5));
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
            single=true;
            bat.getPoint+=dis*0.2;
          }
        }else{
          if(dis>=100){
            bat.homerun_n+=1;
            homerun=true;
            bat.getPoint+=dis;
          }else{
            bat.getPoint+=dis*0.1;
            single=true;
          }
        }
      }
    }
  }

  void ballFly() {
    if(dir==-2){
      x-=15;
    }else if(dir==-1){
      x-=8;
    }else if(dir==1){
      x+=8;
    }else if(dir==2){
      x+=15;
    }
    y-=v;
    v-=1;
    if(s>0){
      s-=0.4;
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
