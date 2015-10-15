//import oscP5.*;
//import netP5.*;

final color BALL_COLOR = color(255, 255, 255);
final color BG_COLOR = color(0, 0, 0);

//final int PORT = 5000;
//OscP5 oscP5 = new OscP5(this, PORT);

int ball_x = 500;
int ball_y = 200;
int ball_s = 20;
int time = 0;
boolean hit=false;
int hitlevel = 0;

void setup(){
  size(1000, 600);
  smooth();
}

void draw(){
  time+=1;
  if(time>120){
    time=0;
    ball_y=200;
    ball_x=500;
    ball_s=20;
    hit=false;
  }
  if(time<=45&&!hit){
    ball_y+=10;
    ball_s+=1;
    background(BG_COLOR);
    fill(BALL_COLOR);
    ellipse(ball_x,ball_y,ball_s,ball_s);
    if(30<=time&&time<=40&&mousePressed){
      hit=true;
      if(30<=time&&time<=32){
        hitlevel=-2;
      }else if(time<=34){
        hitlevel=-1;
      }else if(time==35){
        hitlevel=0;
      }else if(time<=37){
        hitlevel=1;
      }else if(time<=40){
        hitlevel=2;
      }
    }
  }
  if(hit){
    ball_y-=10;
    ball_s-=1;
    if(hitlevel==-2){
      ball_x-=10;
    }else if(hitlevel==-1){
      ball_x-=5;
    }else if(hitlevel==1){
      ball_x+=5;
    }else if(hitlevel==2){
      ball_x+=10;
    }
    background(BG_COLOR);
    ellipse(ball_x,ball_y,ball_s,ball_s);
  }
}
