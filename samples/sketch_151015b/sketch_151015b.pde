// Yuri Socher Bichibichi
// GNU GPL v2
// 2015
// O processing permite o uso de PGraphics e ArrayList, mas eles so deixam seu programa lagado!
// Processing allows the use of PGraphics and ArrayList, but they only leave your program with lag!
   
Configuration configuration;
Player player;
Computer computer;
int lastMillis = millis();
static final float SQRT_2 = sqrt(2);
static final int BACKGROUND = 20;
boolean rd = false;
   
void setup () {
  size(640, 640);
  frameRate(80);
  cursor(CROSS);
  smooth();
  textAlign(CENTER, CENTER);
  configuration = new Configuration();
  player = new Player();
  computer = new Computer();
}
   
void draw() {
  background(BACKGROUND);
  switch(configuration.getScreen()) {
    case Configuration.MENU:
      loopMenu();
      break;
    case Configuration.GAME:
      loopGame();
      drawScore();
      break;
    case Configuration.OVER:
      loopMenu();
      loopGame();
      break;
  }
  drawFPS();
}
   
void loopMenu() {
  pushStyle();
  String msg = "";
  if (player.getScore() >= 0) {
    msg = "press space to new game\n\n";
    if (player.getScore() < 30);
    else if (player.getScore() < 50) {
      msg += "\ngood!\n";
    } else if (player.getScore() < 100) {
      msg += "\ngreat!\n";
    } else if (player.getScore() < 200) {
      msg += "\nfantastic!\n";
    } else {
      msg += "\nperfect!\n";
    }
    msg += player.getScore() + " pts\n\n";
    msg += "comment your score\nfavorite and tweak this!\n" + configuration.getFace();
  } else {
    msg = "press space to start game";
  }
  text(msg, 0, 0, width, height);
  popStyle();
}
   
void loopGame() {
  computer.draw();
  computer.update();
  player.update(computer.getShots());
  player.draw();
}
   
void mousePressed() {
  switch(configuration.getScreen()) {
    case Configuration.GAME:
      player.newShot(new PVector(mouseX, mouseY));
      break;
  }
}
   
void keyPressed() {
  switch(keyCode) {
    case (int) 's':
    case (int) 'S':
      frameRate(10);
      break;
    case (int) 'x':
    case (int) 'X':
      frameRate(80);
      break;
    case (int) 'p':
    case (int) 'P':
      noLoop();
      break;
    case (int) 'l':
    case (int) 'L':
      loop();
      break;
    case (int) 'r':
    case (int) 'R':
      redraw();
      break;
    case (int) ' ':
      if (configuration.getScreen() == Configuration.MENU ||
          configuration.getScreen() == Configuration.OVER) {
        configuration.restart();
      }
      break;
  }
}
   
void drawFPS() {
  if (millis() - lastMillis > 100) {
    lastMillis = millis();
    println("fps:" + frameRate);
  }
}
   
void drawScore() {
  text(player.getScore() + "", 0, 0, width, height);
}
 
/**
 * configurations of game
 * @author  Yuri Socher Bichibichi
 * @version %I%, %G%
 */
class Configuration {
   
  /**
   * face end game screen
   */
  private String face = "";
 
  /**
   * game screen
   */
  private int screen;
 
  /**
   * menu game screen
   */
  public static final int MENU = 0;
 
  /**
   * game screen
   */
  public static final int GAME = 1;
 
  /**
   * end game screen
   */
  public static final int OVER = 2;
   
  /**
   * Constructor
   */
  public Configuration() {
    screen = MENU;
  }
 
  /**
   * @return Configuration.MENU, Configuration.GAME or Configuration.OVER
   */
  public int getScreen() {
    return screen;
  }
 
  /**
   * @return current face
   */
  public String getFace() {
    return face;
  }
   
  /**
   * @param  Configuration.MENU, Configuration.GAME or Configuration.OVER
   * @return        fluent interface
   */
  public Configuration setScreen(int screen) {
    this.screen = screen;
    return this;
  }
   
  /**
   * reset configuration
   */
  public void restart() {
    player.reset();
    computer.reset();
    screen = GAME;
    randomFace();
  }
 
  /**
   * set face with a random asc art one line
   */
  private void randomFace() {
    switch((int)random(15)) {
    // !@#$%&* site that doesn't save it in utf-8
      case 0: face = "\u01B8\u0335\u0321\u04DC\u0335\u0328\u0304\u01B7"; break;
      case 2: face = "\u0028\u0020\u0360\u00B0\u0020\u035C\u0296\u0020\u0360\u00B0\u0029\uFEFF"; break;
      case 3: face = "\u0028\u203E\u2323\u203E\u0029\u2649"; break;
      case 4: face = "\u02C1\u02DA\u1D25\u02DA\u02C0"; break;
      case 5: face = "\u0295\u0298\u0305\u035C\u0298\u0305\u0294"; break;
      case 6: face = "\u2180\u25E1\u2180"; break;
      case 7: face = "\u263C\u203F\u263C"; break;
      case 8: face = "\u3010\u30C4\u3011"; break;
      case 9: face = "\u2205\u203F\u2205"; break;
      case 10: face = "\u005E\u2A00\u1D25\u2A00\u005E"; break;
      case 11: face = "\u1566\u0028\u00F2\u005F\u00F3\u02C7\u0029\u1564"; break;
      case 12: face = "\u1566\u0028\u00F2\u005F\u00F3\u02C7\u0029\u1564"; break;
      case 13: face = "\u0028\u2310\u25A0\u005F\u25A0\u0029\u002D\u002D\uFE3B\u2566\u2564\u2500\u0020\u002D\u0020\u002D\u0020\u002D\u0020\u0028\u0020\u0029"; break;
      case 14: face = "\u250F\u0028\u002D\u005F\u002D\u0029\u251B\u2517\u0028\u002D\u005F\u002D\uFEFF\u0020\u0029\u2513\u2517\u0028\u002D\u005F\u002D\u0029\u251B\u250F\u0028\u002D\u005F\u002D\u0029\u2513"; break;
    }
  }
}
 
/**
 * player's opponent
 * @author  Yuri Socher Bichibichi
 * @version 0.0.1
 */
class Computer {
   
  /**
   * computer's shots/bubbles
   */
  private Shot[] shots;
 
  /**
   * number of shots (grows with time)
   */
  private int countShots;
 
  /**
   * count last time of update
   */
  private int lastMillis;
 
  /**
   * max number of shots/bubbles
   */
  public static final int MAX_SHOTS = 20;
   
  /**
   * Constructor
   */
  public Computer() {}
   
  /**
   * reset computer with defaults
   */
  public void reset() {
    lastMillis = millis();
    shots = new Shot[MAX_SHOTS];
    countShots = 1;
    for (int i = 0; i < shots.length; ++i) {
      if (i < countShots) {
        shots[i] = newShot(random(20));
      } else {
        shots[i] = null;
      }
    }
  }
   
  /**
   * @return computer's shots/bubbles
   */
  public Shot[] getShots() {
    return shots;
  }
   
  /**
   * update shots/bubbles, increment number of shots/bubbles and check collisions
   */
  public void update() {
    if (countShots < MAX_SHOTS && millis() > lastMillis + countShots * 1000) {
      shots[countShots] = newShot();
      ++countShots;
      lastMillis = millis();
    }
    updateShots();
    collisionThisShots();
  }
   
  /**
   * update shots/bubbles and increment number of shots/bubbles
   */
  public void updateShots() {
    for (int i = 0; i < countShots; ++i) {
      Shot shot = shots[i];
      shot.update();
      if (shot.outScreen() || !shot.getValid()) {
        shots[i] = newShot();
      }
    }
  }
   
  /**
   * @return a shot in random position
   */
  private Shot newShot() {
    return newShot(1);
  }
   
  /**
   * @return a shot in random position
   */
  private Shot newShot(float multiplier) {
    float x, y;
    if (random(1) >= .5f) {
      y = random(height);
      if (random(1) >= .5f) {
        x = 0 - Shot.INITAL_SIZE / 2 * multiplier;
      } else {
        x = width + Shot.INITAL_SIZE / 2 * multiplier;
      }
    } else {
      x = random(width);
      if (random(1) >= .5f) {
        y = 0 - Shot.INITAL_SIZE / 2 * multiplier;
      } else {
        y = height + Shot.INITAL_SIZE / 2 * multiplier;
      }
    }
    PVector position = new PVector(x, y);
   
    float forceX = -(x - (width / 2)) / 500;
    float forceY = -(y - (height / 2)) / 500;
    PVector force = new PVector(forceX, forceY);
   
    Shot shot = new Shot(force, position);
    return shot;
  }
   
  /**
   * draw computer's shots
   */
  public void draw() {
    drawShots();
  }
   
  /**
   * draw computer's shots
   */
  public void drawShots() {
    for (Shot shot : shots) {
      if (shot != null) {
        shot.draw();
      }
    }
  }
   
  /**
   * check collisions of shots
   */
  public void collisionThisShots() {
    for (int i = 0; i < countShots; ++i) {
      for (int j = i; j < countShots; ++j) {
        if (i != j) {
          shots[i].collision(shots[j]);
        }
      }
    }
  }
}
  
/**
 * shots, score and base of the player
 * @author  Yuri Socher Bichibichi
 * @version 0.0.1
 */
class Player {
   
  /**
   * player's shots
   */
  private Shot[] shots;
 
  /**
   * player's base
   */
  private Base base;
 
  /**
   * player's score (number of computer's shots )
   */
  private int score;
   
  /**
   * Constructor
   * score initializes with -1 to be explicit that isn't valid
   */
  public Player() {
    score = -1;
  }
   
  /**
   * reset player with defaults
   */
  public void reset() {
    score = 0;
    shots = new Shot[10];
    base = new Base(new PVector(width / 2, height / 2));
  }
   
  /**
   * @return player's shots
   */
  public Shot[] getShots() {
    return shots;
  }
   
  /**
   * @return player's score
   */
  public int getScore() {
    return score;
  }
   
  /**
   * create a nem shot if array of player's shots isn't full
   * @param  mouse mouse position
   * @return       fluent interface
   */
  public Player newShot(PVector mouse) {
    PVector force = new PVector(mouse.x, mouse.y);
    force.sub(base.getCenter());
    force.div(10);
   
    PVector pos = calculateSight(mouse);
   
    for (int i = 0; i < shots.length; ++i) {
      if (shots[i] == null) {
        shots[i] = new Shot(force, pos);
        break;
      }
    }
   
    return this;
  }
   
  /**
   * check collisions and update shots
   * @param enemies
   */
  public void update(Shot[] enemies) {
    collisionShots(enemies);
    base.update(enemies);
    base.updateFriendlyFire(shots);
    updateShots();
  }
   
  /**
   * update player's shots
   */
  public void updateShots() {
    for (int i = 0; i < shots.length; ++i) {
      if (shots[i] != null) {
        Shot shot = shots[i];
        shot.update();
        if (shot.outScreen()) {
          shot.setExplosion(true);
        }
        if (!shot.getValid()) {
          shots[i] = null;
        }
      }
    }
  }
   
  /**
   * draw shots, base and sight
   */
  public void draw() {
    drawShots();
    drawSight(new PVector(mouseX, mouseY));
    base.draw();
  }
   
  /**
   * draw shots
   */
  public void drawShots() {
    for (Shot shot : shots) {
      if (shot != null) {
        shot.draw();
      }
    }
  }
     
  /**
   * draw sight
   * @param mouse mouse position
   */
  public void drawSight(PVector mouse) {
    pushStyle();
    fill(255);
    stroke(255);
    PVector pos = calculateSight(mouse);
    ellipse(pos.x, pos.y, Shot.INITAL_SIZE / 2, Shot.INITAL_SIZE / 2);
    popStyle();
  }
   
  /**
   * calculate center position of sight
   * @param  mouse mouse position
   * @return       center position of sight
   */
  private PVector calculateSight(PVector mouse) {
    PVector pos = PVector.sub(mouse, base.getCenter());
    pos.normalize();
    pos.mult(base.getSize() / 2);
    return PVector.add(pos, base.getCenter());
  }
   
  /**
   * check collisions
   * @param enemies computer's shots
   */
  public void collisionShots(Shot[] enemies) {
    collisionThisShots();
    collisionEnemiesShots(enemies);
  }
   
  /**
   * check collisions of player's shots with they even
   */
  public void collisionThisShots() {
    for (int i = 0; i < shots.length; ++i) {
      for (int j = i; j < shots.length; ++j) {
        if (i != j && shots[i] != null && shots[j] != null) {
          shots[i].collision(shots[j]);
        }
      }
    }
  }
   
  /**
   * check collistions of player's shots with computer's shots
   * @param enemies computer's shots
   */
  public void collisionEnemiesShots(Shot[] enemies) {
    for (int i = 0; i < shots.length; ++i) {
      for (int j = 0; j < enemies.length; ++j) {
        if (enemies[j] != null && shots[i] != null) {
          boolean explosion = enemies[j].getExplosion();
          if (shots[i].collision(enemies[j]) && !explosion) {
            ++score;
          }
        }
      }
    }
  }
}
 
/**
 * base
 * @author  Yuri Socher Bichibichi
 * @version 0.0.1
 */
class Base {
   
  /**
   * radius of base
   */
  private float size;
 
  /**
   * last size
   */
  private float lastSize;
 
  /**
   * center position
   */
  private PVector center;
   
  /**
   * initial size
   */
  public static final int INITAL_SIZE = 60;
   
  /**
   * Constructor
   * @param  center center position
   */
  public Base(PVector center) {
    size = INITAL_SIZE;
    lastSize = INITAL_SIZE;
    this.center = center;
  }
   
  /**
   * @return size
   */
  public float getSize() {
    return size;
  }
   
  /**
   * @return center position
   */
  public PVector getCenter() {
    return center;
  }
   
  /**
   * draw base
   */
  public void draw() {
    if (size < (width + height) / 2 * SQRT_2) {
      pushStyle();
      strokeWeight(2);
      if (lastSize == size) {
        stroke(255);
      } else {
        stroke(255, 0, 0);
      }
      noFill();
      ellipse(center.x, center.y, size, size);
      popStyle();
      lastSize = size;
    }
  }
   
  /**
   * check collisions of player's shots with base
   * @param shots player's shots
   */
  public void updateFriendlyFire(Shot[] shots) {
    for (Shot shot : shots) {
      if (shot != null && shot.getExplosion()) {
        collision(shot);
      }
    }
  }
   
  /**
   * check collisions of computer's shots with base and check if base is too large (then game is over)
   * @param enemies computer's shots
   */
  public void update(Shot[] enemies) {
    for (Shot enemy : enemies) {
      if (enemy != null) {
        collision(enemy);
      }
    }
    if (size > (width + height) / 2) {
      configuration.setScreen(Configuration.OVER);
    }
  }
   
  /**
   * check collision of base with computer's shot
   * @param  enemy computer's shot
   * @return       if has or no collision
   */
  public boolean collision(Shot enemy) {
    float distance = center.dist(enemy.getPosition());
    if ((distance - size / 2) <= (enemy.getSize() / 2)) {
      size += 0.5;
      enemy.setExplosion(true);
      return true;
    }
    return false;
  }
}
 
/**
 * shot/bubble
 * @author  Yuri Socher Bichibichi
 * @version 0.0.1
 */
class Shot {
   
  /**
   * size of shot
   */
  private float size;
 
  /**
   * speed
   */
  private PVector force;
 
  /**
   * position
   */
  private PVector position;
 
  /**
   * explosion
   */
  private boolean explosion;
 
  /**
   * size is too large
   */
  private boolean valid;
   
  /**
   * tail of shot
   */
  private PVector oldPositions[];
 
  /**
   * index begin of tail's array
   */
  private int indexPosition;
 
  /**
   * last time (for update tail)
   */
  private int lastMillis;
   
  /**
   * initial size
   */
  public static final int INITAL_SIZE = 20;
 
  /**
   * max size
   */
  public static final int MAX_SIZE = 100;
   
  /**
   * Constructor
   * @param  force    speed of shot
   * @param  position position
   */
  public Shot(PVector force, PVector position) {
    oldPositions = new PVector[10];
    oldPositions[0] = new PVector(position.x, position.y);
    indexPosition = 1;
    lastMillis = 0;
   
    size = INITAL_SIZE;
    this.force = force;
    this.position = position;
    explosion = false;
    valid = true;
  }
   
  /**
   * @return size
   */
  public float getSize() {
    return size;
  }
   
  /**
   * @return explosion
   */
  public boolean getExplosion() {
    return explosion;
  }
   
  /**
   * @param  explosion explosion
   * @return           fluent interface
   */
  public Shot setExplosion(boolean explosion) {
    this.explosion = explosion;
    return this;
  }
   
  /**
   * @return speed
   */
  public PVector getForce() {
    return force;
  }
   
  /**
   * @param  force speed
   * @return       fluent interface
   */
  public Shot setForce(PVector force) {
    this.force = force;
    return this;
  }
   
  /**
   * @return position
   */
  public PVector getPosition() {
    return position;
  }
     
  /**
   * @param  position position
   * @return          fluent interface
   */
  public Shot setPosition(PVector position) {
    this.position = position;
    return this;
  }
   
  /**
   * @return if is valid then size is less than max size
   */
  public boolean getValid() {
    return valid;
  }
   
  /**
   * draw shot
   */
  public void draw() {
    drawTail();
   
    pushStyle();
    noFill();
    strokeWeight(2);
    if (explosion) {
      stroke(255, 0, 0);
    } else {
      stroke(255);
    }
    ellipse(position.x, position.y, size, size);
    popStyle();
   
  }
 
  /**
   * draw shot's tail
   */
  private void drawTail() {
    PVector lastOld = null;
    for (int i = indexPosition; i < oldPositions.length + indexPosition; ++i) {
      int index = i % oldPositions.length;
      PVector old = oldPositions[index];
      if (old != null) {
        if (lastOld != null) {
          pushStyle();
          noFill();
   
          int c = (i - indexPosition) * ((200 - BACKGROUND) / oldPositions.length);
   
          stroke(BACKGROUND, c + BACKGROUND, BACKGROUND, 30);
          strokeWeight(INITAL_SIZE / 2);
          line(lastOld.x, lastOld.y, old.x, old.y);
   
          stroke(BACKGROUND, c + BACKGROUND, BACKGROUND);
          strokeWeight(INITAL_SIZE / 4);
          line(lastOld.x, lastOld.y, old.x, old.y);
   
          popStyle();
        }
        lastOld = old;
      }
    }
  }
     
  /**
   * update shot
   */
  public void update() {
   
    int lastOldPosition = (oldPositions.length + indexPosition - 1) % oldPositions.length;
    if ((millis() - lastMillis) > 10) {
      oldPositions[indexPosition] = new PVector(position.x, position.y);
      ++indexPosition;
      if (indexPosition >= oldPositions.length) {
        indexPosition -= oldPositions.length;
      }
      lastMillis = millis();
    } else {
      oldPositions[indexPosition] = new PVector(position.x, position.y);
    }
   
    if (explosion) {
      if (size < MAX_SIZE / 2) {
        size += sqrt(size / 2);
 
      } else if (size < MAX_SIZE) {
        size += 10000 / pow(size, 2);
 
      } else {
        valid = false;
      }
      force.div(2);
    }
    position.add(force);
  }
   
  /**
   * check collision
   * if yes, set explosion in this and other shot
   * @param  shot other shot
   * @return      if has collision
   */
  public boolean collision(Shot shot) {
    float distance = position.dist(shot.getPosition());
    if (distance < (size + shot.getSize()) / 2) {
      explosion = true;
      shot.setExplosion(true);
      return true;
    }
    return false;
  }
   
  /**
   * @return if shot is out screen
   */
  public boolean outScreen() {
    return ((position.x + size < 0) && (force.x < 0)) ||
           ((position.x - size > width) && (force.x > 0)) ||
           ((position.y + size < 0) && (force.y < 0)) ||
           ((position.y - size > height) && (force.y > 0));
  }
}

