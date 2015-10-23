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
final int size_y=700;
final float ball_sy=425;
final float pit_Dis=140;
final int ball_max=10;
final int[] speed={100,150,0,-1};
int ball_n;
Ball ball = new Ball(ball_sy,pit_Dis);
PImage btg;
PImage[] pitcher;
PImage ground;
Batter bat = new Batter(ball_sy,pit_Dis);
int time;
int difficulty; // 0:easy, 1:normal, 2:hard, 3:extreme

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
  bat.x=(size_x-bat.LENGTH*1.2)/2;
  time=-180;
  ball.ballReset();
  bat.batReset();
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
        difficulty = (difficulty+1) % 3;
      }
      if (keyCode == UP) {
        // FIXME: とりま二段階なのでぷらす
        difficulty = (difficulty+2) % 3;
      }
      if(key=='z'){
        difficulty=3;
      }
      break;
    case Configuration.GAME:
      if(keyCode==RIGHT){
        bat.x+=10;
      }
      if(keyCode==LEFT){
        bat.x-=10;
      }
  }
//  if (mousePressed) {
//    background(BG_COLOR);
//    configuration.setScreen(Configuration.RESULT);
//  }
}

void loopMenu() {
  background(BG_COLOR);
  textSize(50);
  fill(255,255,255);
  text("CHOOSE DIFFICULTY", size_x*0.5, 50);
  text("AND PRESS SPACE KEY TO START", size_x*0.5, 100);
  if(difficulty == 0) {
    text(">EASY<",size_x*0.5,300);
    text("NORMAL",size_x*0.5,400);
    text("HARD",size_x*0.5,500);
  }else if(difficulty == 1) {
    text("EASY", size_x*0.5,300);
    text(">NORMAL<",size_x*0.5,400);
    text("HARD",size_x*0.5,500);
  }else if(difficulty == 2) {
    text("EASY", size_x*0.5,300);
    text("NORMAL",size_x*0.5,400);
    text(">HARD<",size_x*0.5,500);
  }else if(difficulty == 3) {
    text("EASY", size_x*0.5,300);
    text("NORMAL",size_x*0.5,400);
    text("HARD",size_x*0.5,500);
    text(">EXTREME<",size_x*0.5,600);
  }

  if(key == ' ') {
    configuration.setScreen(Configuration.GAME);
  }
}

void loopGame() {
  time++;
  float alpha=alphaCalc();
  bat.batPreSet(btg,alpha);
  if(ball_n>=ball_max){
    configuration.setScreen(Configuration.RESULT);
  }else if(time>=180){
    time=0;
    ball_n+=1;
    ball.ballReset();
    bat.batReset();
  }
  if(time==0){
    ball.ballPreSet(speed[difficulty]);
  }
  if(time<=60){
  bgSet();
    if(time<0){
      fill(TX_COLOR);
      textAlign(CENTER,BOTTOM);
      textSize(100);
      text(int(time*(-1)/60+1),size_x*0.495,size_y*0.55);
      pitSet(0);
      bat.batSet();
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
    if(ball.y>=size_y+ball.s){
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
        text("distance:"+ball.dis+"m",size_x*0.5,size_y*0.6);
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
  if(key == ENTER) {
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

void pitSet(int i){
  image(pitcher[i],size_x*0.5-8,ball_sy-10,64,88);
}

void bgSet(){
  image(ground,0,0,size_x,size_y);
}

class Batter{
  float l;
  final float w=100;
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

  void batReset(){
    l=LENGTH;
    y=ball_sy+pit_Dis;
    t=0;
    swing=false;
  }
  
  void batPreSet(PImage btgg, float alphaa){
    btg=btgg;
    alpha=alphaa;
  }

  void batSet(){
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
    if(alpha<0.1){
      wid=w*0.1;
    }else{
      wid=w*alpha;
    }
    image(btg,0,0,l,wid);
    resetMatrix();
  }

}

class Ball{
  float x;
  float x2;
  float x3;
  float y;
  float s;
  float s2;
  float s3;
  float v;
  float v2;
  int dir;
  int dis;
  boolean hit;
  boolean homerun;
  boolean single;
  float ball_sy;
  float pit_Dis;
  int kmph;
  int frame;
//  final float homerun_Y=500;
//  final float hit_Y=200;

  Ball(float le,float dis){
    ball_sy=le;
    pit_Dis=dis;
  }

  void ballPreSet(int speed){
    float change=0;
    if(speed==0){
      kmph=int(random(100,160));
    }else if(speed==-1){
      if(random(0,1)>0.5){
        change=random(10,20);
        kmph=int(random(100,130));
      }else{
        kmph=int(random(130,160));
      }
    }else{
      kmph=speed;
    }
    frame=int(18.44/(kmph*1000/3600)*60);
    if(change>0){
      if(random(0,1)>0.5){
        change*=(-1);
      }
      x2=-change*0.2;
      x3=change*2*(1+0.2*frame)/((frame-1)*frame);
    }
  }
  
  void ballReset(){
    x=(size_x)/2;
    x2=0;
    x3=0;
    y=ball_sy;
    s=4;
    s2=0;
    s3=0;
    v=0;
    v2=0;
    dir=-3;
    dis=0;
    hit=false;
    homerun=false;
    single=false;
  }

  void ballThrow(){
    y+=v;
    v+=v2;
    v2+=pit_Dis*6/((frame-2)*(frame-1)*frame);
    s+=s2;
    s2+=s3;
    s3+=16.0*6/((frame-2)*(frame-1)*frame);
    x+=x2;
    x2+=x3;
    fill(BALL_COLOR);
    ellipse(x,y,s,s);
  }

  void hitted(int time, Batter bat,float alpha){
    int t=bat.t;
    if(frame+64<=time+t&&time+t<=frame+65&&2<=t&&t<=6&&
       x-10<=bat.x+bat.LENGTH*0.6&&bat.x+bat.LENGTH*0.6<=x+10){
      hit=true;
      s=20;
      float alp;
      if(alpha<0.1){
        alp=0.1;
      }else{
        alp=alpha;
      }
      dis = int((50+alp*500)*random(0.5,1.5));
      if(3<=t&&t<=5){
        if(t==4){
          dir=0;
          x2=0;
          if(dis>=120){
            bat.homerun_n+=1;
            homerun=true;
            bat.getPoint+=dis*2;
            v=32;
            v2=1;
          }else{
            single=true;
            bat.getPoint+=dis*0.2;
            v=20;
            v2=0.7;
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
      if(t==6){
        dir=-2;
        v=28;
        v2=1;
        x2=-18;
      }else if(t==5){
        dir=-1;
        x2=-8;
        if(homerun){
          v=31;
          v2=1;
        }else{
          v=20;
          v2=0.7;
        }
      }else if(t==3){
        dir=1;
        x2=8;
        if(homerun){
          v=33;
          v2=1;
        }else{
          v=22;
          v2=0.7;
        }
      }else if(t==2){
        dir=2;
        v=33;
        v2=1;
        x2=18;
      }
    }
  }

  void ballFly() {
    x+=x2;
    y-=v;
    v-=v2;
    if(s>0){
      s-=0.36;
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
