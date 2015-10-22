import oscP5.*;
import netP5.*;

final int N_CHANNELS = 4;
final int BUFFER_SIZE = 30;
float[][] buffer = new float[N_CHANNELS][BUFFER_SIZE];
int pointer = 0;
final int PORT = 5000;
OscP5 oscP5 = new OscP5(this, PORT);

final color TX_COLOR = color(255,255,0);
final color BALL_COLOR = color(255,255,255);
final color BAT_COLOR = color(204,102,0);

final int size_x=960;
//final int size_y=556;
final int size_y=700;
final int ball_sy=415;
final int pit_Dis=150;
final int ball_max=10;
int ball_n;
Ball ball = new Ball(ball_sy,pit_Dis);
PImage btg;
PImage[] pitcher;
PImage ground;
Batter bat = new Batter(ball_sy,pit_Dis);
int time;

void setup(){
  size(size_x,size_y);
  ball_n=0;
  bat.homerun_n=0;
  bat.getPoint=0;
  time=-180;
  ball.ballSet();
  ground = loadImage("jingu.jpg");
  bgSet();
  smooth();
  btg = loadImage("bat.jpg");
  pitcher = new PImage[11];
  for(int i=1;i<=pitcher.length;i++){
    pitcher[i-1]=loadImage("sawa"+i+".jpg");
  }
}

void draw(){
  time+=1;
  float alpha=alphaCalc();
  bat.preSet(btg,alpha);
  if(ball_n>=ball_max){
    bgSet();
    fill(TX_COLOR);
    textAlign(CENTER);
    textSize(50);
    text("finish",size_x*0.5,size_y*0.4);
    text(bat.homerun_n + " HOMERUN",size_x*0.5,size_y*0.6);
    text("POINTS: " + bat.getPoint,size_x*0.5,size_y*0.8);
    if(mousePressed){
      setup();
    }
    return;
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
  image(pitcher[i],size_x*0.5-8,ball_sy,64,88);
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
  int ball_sy;
  int pit_Dis;
  
  Batter(int le, int dis){
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
    image(btg,0,0,l,w*0.1);//w*alpha
    resetMatrix();
  }
  
  void swing(){
    t+=1;
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
  boolean single;
  int ball_sy;
  int pit_Dis;
  
  Ball(int le, int dis){
    ball_sy=le;
    pit_Dis=dis;
  }

  void ballSet(){
    x=(size_x)/2;
    y=size_y-400;
    s=5;
    v=1;
    dir=-3;
    hit=false;
    homerun=false;
    single=false;
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
