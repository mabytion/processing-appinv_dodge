import processing.net.*;

class Player
{
  int size = 10;
  float x, y;
  
  public Player(int size)
  {
    this.size = size;
  }
  
  public void go(float x, float y)
  {
    if(x < 0) x = 0;
    else if(x > width) x = width;
    
    if(y < 0) y = 0;
    else if(y > height) y = height;
    
    pushMatrix();
    translate(x, y);
    fill(0);
    circle(0, 0, size);
    popMatrix();
  }
}

class Bullet
{
  int size;
  int speed;
  float degree;
  int side;
  float _x, _y;
  float x, y;
  float ax, ay;
  boolean goFlags = true;
  
  public Bullet()
  {
    size = (int)random(30, 60);
    speed = (int)random(2,  10);
    side = (int)random(1, 5);
    if(side == 5) side = 4;
    
    switch(side)
    {
      case 1: // top
      {
        _x = (int)random(0, width);
        _y = 0;
        degree = (int)random(0+90*(_x/width), 90+90*(_x/width));
        break;
      }
      case 2: // left o
      {
        _x = 0;
        _y = (int)random(0, height);
        degree = (int)random(0-90*(_y/height), 90-90*(_y/height));
        break;
      }
      case 3: // right
      {
        _x = width;
        _y = (int)random(0, height);
        degree = (int)random(90+90*(_y/height), 180+90*(_y/height));
        break;
      }
      case 4: // bottom o
      {
        _x = (int)random(0, width);
        _y = height;
        degree = (int)random(270-90*(_x/width), 360-90*(_x/width));
        break;
      }
      default:
      {
        degree = (int)random(0, 360);
        _x = 0;
        _y = 0;
      }
    }
  }
  
  public void go()
  {
    pushMatrix();
    translate(_x, _y);
    fill(#FF0000);
    rotate(radians(degree));
    rect(x, y, size, size);
    popMatrix();
    
    ax = getAX();
    ay = getAY();
    
    if((X > ax - size/2) && (X < ax + size/2) && (Y < ay + size/2) &&  (Y > ay - size/2))
    {
      death = true;
    }
    
    x+=speed;
    
    //if(x>width*1.5)
    //{
    //  goFlags = false;
    //}
    
    if(ax > width || ax < 0 || ay > height || ay < 0)
    {
      goFlags = false;
    }
  }
  public boolean getGoFlags()
  {
    return goFlags;
  }
  public float getAX()
  {
    int sign = 0;
    float _degree;
    float theta = 0;
    
    if((degree + 90) >= 360)
    {
      _degree = (degree + 90) - 360;
    }
    else
    {
      _degree = degree + 90;
    }
    
    if(_degree > 0 && _degree < 90)
    {
      theta = 90 - _degree;
      sign = 0;
    }
    else if(_degree > 90 && _degree < 180)
    {
      theta = _degree - 90;
      sign = 0;
    }
    else if(_degree > 180 && _degree < 270)
    {
      theta = 270 - _degree;
      sign = 1;
    }
    else if(_degree > 270 && _degree < 360)
    {
      theta = _degree - 270;
      sign = 1;
    }
    else if(_degree == 0)
    {
      return 0;
    }
    else if(_degree == 90)
    {
      return (_x + x);
    }
    else if(_degree == 180)
    {
      return 0;
    }
    else if(_degree == 270)
    {
      return (_x - x);
    }
    
    if(sign == 0)
    {
      return (_x + (cos(radians(theta)) * x));
    }
    else
    {
      return (_x - (cos(radians(theta)) * x));
    }
  }
  public float getAY()
  {
    int sign = 0;
    float _degree;
    float theta = 0;
    
    if((degree + 90) >= 360)
    {
      _degree = (degree + 90) - 360;
    }
    else
    {
      _degree = degree + 90;
    }
    
    if(_degree > 0 && _degree < 90)
    {
      theta = 90 - _degree;
      sign = 1;
    }
    else if(_degree > 90 && _degree < 180)
    {
      theta = _degree - 90;
      sign = 0;
    }
    else if(_degree > 180 && _degree < 270)
    {
      theta = 270 - _degree;
      sign = 0;
    }
    else if(_degree > 270 && _degree < 360)
    {
      theta = _degree - 270;
      sign = 1;
    }
    else if(_degree == 0)
    {
      return (_y - x);
    }
    else if(_degree == 90)
    {
      return 0;
    }
    else if(_degree == 180)
    {
      return (_y + x);
    }
    else if(_degree == 270)
    {
      return 0;
    }
    
    if(sign == 0)
    {
      return (_y + (sin(radians(theta)) * x));
    }
    else
    {
      return (_y - (sin(radians(theta)) * x));
    }
  }
  
}

Player p = new Player(50);
ArrayList<Bullet> bl;
float X, Y;
float tX, tY;
int ball = 80;
boolean death = false;
Server s;
Client c;

void setup()
{
  //size(500, 500);
  fullScreen();
  textFont(createFont("맑은 고딕",32));
  textAlign(CENTER, CENTER);
  
  X = width/2;
  Y = height/2;
  s = new Server(this, 12345);
  bl = new ArrayList<Bullet>();
  for(int i=0;i<ball;i++)
  {
    bl.add(new Bullet());
  }
}

void draw()
{
  background(255);
  
  c = s.available();
  
  if(c != null)
  {
    String msg = c.readString();
    int n = msg.indexOf("\r\n\r\n")+4;
    msg = msg.substring(n);
    
    for(int i=0;i<1;i++)
    {
      String[] ho = msg.split("/");
      tX += (Float.parseFloat(ho[0]) / 1);
      tY += (Float.parseFloat(ho[1]) / 1);
    }
    
    X -= tX/1;
    Y += tY/1;
    tX = 0;
    tY = 0;
  }
  
  if(!death)
  {
    try
    {
      for(int i=0;i<ball;i++)
      {
        if(bl.get(i).getGoFlags())
        {
          bl.get(i).go();
        }
        else
        {
          bl.remove(i);
          bl.add(new Bullet());
        }
      }
      
      
    }
    catch(IndexOutOfBoundsException e)
    {
      for(int i=bl.size();i<ball;i++)
      {
        bl.add(new Bullet());
      }
    }
    
    p.go(X, Y);
    //delay(5);
  }
  else
  {
    
    text("죽음\nR재시작", width/2 , height/2);
    
  }
  
  
}

void keyPressed()
{
  switch(key)
  {
    case 'r':
      death = false;
      bl = new ArrayList<Bullet>();
      X = width/2;
      Y = height/2;
      break;
  }
}
