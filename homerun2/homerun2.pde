import oscP5.*;
import netP5.*;

final int N_CHANNELS = 4;
final int BUFFER_SIZE = 30;
float[][] buffer = new float[N_CHANNELS][BUFFER_SIZE];
int pointer = 0;
final int PORT = 5000;
OscP5 oscP5 = new OscP5(this, PORT);

final color BALL_COLOR = color(255, 255, 255);
final color BG_COLOR = color(0, 0, 0);
final color BAT_COLOR = color(204,102,0);

int ball_x = 500;
int ball_y = 200;
int ball_s = 20;
int bat_x = 400;
final int bat_l = 200;
float bat_w = 20;
float bat_wn = 20;
int time = -180;
boolean hit=false;
int hitlevel = -3;

void setup(){
  size(1000, 600);
  background(BG_COLOR);
  fill(BAT_COLOR);
  rect(bat_x,550,bat_l,bat_wn);
  smooth();
}

void draw(){
  time+=1;
  float alpha=0;
  for(int i=0;i<N_CHANNELS;i++){
    for(int j=0;j<BUFFER_SIZE;j++){
      alpha+=buffer[i][j];
    }
  }
  alpha=alpha/(N_CHANNELS*BUFFER_SIZE);
//  bat_wn = bat_w*alpha*10;
  if(time>120){
    time=0;
    ball_y=200;
    ball_x=500;
    ball_s=20;
    hit=false;
    hitlevel=-3;
    background(BG_COLOR);
    fill(BAT_COLOR);
    rect(bat_x,550,bat_l,bat_wn);
  }
  if(time>=21&&!hit){
    ball_y+=10;
    ball_s+=1;
    background(BG_COLOR);
    fill(BALL_COLOR);
    ellipse(ball_x,ball_y,ball_s,ball_s);
    fill(BAT_COLOR);
    if(hitlevel==-3){
      rect(bat_x,550,bat_l,bat_wn);
    }else{
      rect(bat_x,550-bat_l,bat_wn,bat_l);
    }
    if(48<=time&&time<=58&&mousePressed&&hitlevel==-3){
      hit=true;
      if(48<=time&&time<=50){
        hitlevel=-2;
      }else if(time<=52){
        hitlevel=-1;
      }else if(time==53){
        hitlevel=0;
      }else if(time<=55){
        hitlevel=1;
      }else if(time<=58){
        hitlevel=2;
      }
    }else if(mousePressed){
      hitlevel=3;
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
    fill(BALL_COLOR);
    ellipse(ball_x,ball_y,ball_s,ball_s);
    fill(BAT_COLOR);
    rect(bat_x,550-bat_l,bat_wn,bat_l);
  }
}

void oscEvent(OscMessage msg){
  float data;
  if(msg.checkAddrPattern("/muse/elements/alpha_relative")){
    for(int ch = 0; ch < N_CHANNELS; ch++){
      data = msg.get(ch).floatValue();
      buffer[ch][pointer] = data;
    }
    pointer = (pointer + 1) % BUFFER_SIZE;
  }
}
