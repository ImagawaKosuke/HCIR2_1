import controlP5.*;
import gab.opencv.*;
import processing.video.*;
import java.awt.*; //java.awtクラスのインポート

Capture video;
OpenCV opencv;
//輪郭の配列
//Contourはデータ型、contoursはオブジェクト名

ArrayList<Contour> contours; //輪郭線集合を格納する動的配列（名前は何でもよい）の宣言
Contour contour; // 各輪郭線を表現するContour型変数（名前は何でもよい）の宣言

PImage outImage;
int w = 640;
int h = 480;
ControlP5 slider;
int Hue_MinValue=5; //閾値の最小値
int Hue_MaxValue=20; //閾値の最大値
int j=0;
int k = 0;
Rectangle box; //外接矩形を表現するRectangle型変数（名前は何でもよい）の宣言
PImage original;


//ブロック崩し用
float block_w = 80, block_h = 20; //ブロックの大きさ
float bar_w = 200, bar_h = 30; //バーの大きさ
int MaxColor;
boolean is_alive[][] = new boolean[8][6]; //ブロックの判定
float ball_x, ball_y, ball_r; //ボールの大きさと位置
float speed_x, speed_y; //ボールのスピード
float x;
int scene = 0; //画面遷移用
boolean S = false;
int gamestart=0; //ゲームスタートしたか否か
int life=3;
int score = 0;
int game = 0;

void setup() {

  size(940, 480);
  rectMode(CENTER);
  //String[] cameras = Capture.list();
  //video = new Capture(this, cameras[98]);//自分用のUSBカメラ
  video = new Capture(this, 640, 480, "Intel(R) RealSense(TM) Depth Camera 415  RGB", 60);//演習室のカメラ
  opencv = new OpenCV(this, w, h);

  //controlP5でGUI作成
  slider = new ControlP5(this);
  slider.addSlider("Hue_MinValue",0,180,Hue_MinValue,660,80,200,20);//閾値の最小値
  slider.addSlider("Hue_MaxValue",0,180,Hue_MaxValue,660,110,200,20);  //閾値の最大値
  MaxColor = 640;
  colorMode(HSB, MaxColor); // HSB表色系(レンジはウィンドウ幅)
  video.start();
  frameRate(120);
  ball_x = 250;
  ball_y = 350;
  ball_r = 20;
  speed_x = 3;
  speed_y = -6;
}

void draw() {
    fill(0,100,500);
    rect(640+150,height/2,300,480);
    fill(0,0,0);
    text("Score" + " " + str(score), 700, 200); //スコア表示
    PImage logo = loadImage("Heart.png"); //ハート表示
    image(logo, 660, 250,50,50);
    text("×" + str(life), 740, 280);//ライフの数
    
  noFill();
  strokeWeight(3);
  opencv.loadImage(video);
  opencv.useColor();
  original = opencv.getSnapshot();
  image(original, 0, 0);
  if(scene==1||S==true){contourmanager();}//ボタンが押された場合
 
  if(scene == 0){ startmanager();}//scene=0の場合スタート画面 初期設定
  else if(scene == 1){ gamecontroller();} //scene=1になり、ゲームを開始する時

}


//キャプチャー
void captureEvent(Capture c) {
  c.read();
}

void contourmanager(){
  
  //画像データをHSV色空間で扱う
  opencv.useColor(HSB);
  opencv.setGray(opencv.getH().clone());
  opencv.inRange(Hue_MinValue, Hue_MaxValue);
  outImage = opencv.getSnapshot();
  //image(outImage, W, 0);
  opencv.loadImage(outImage);
     //輪郭を抽出
  float a=100000000;

  //検出された輪郭の数だけ、輪郭線を赤色で書く
  //Contourはデータ型、contoursはオブジェクト名
  contours=opencv.findContours(false,true);      //領域の外側の輪郭線のみを大きい順に抽出
  for (int i=0; i<contours.size(); i++) {        // 輪郭線数だけ繰り返し
      contour=contours.get(i);  
      // i番目の輪郭線データをcontourに格納
      noFill(); // 内部は塗りつぶさないように設定
      stroke(0,1000,1000);                               // 描画色を赤に設定
      strokeWeight(2);                               // 線の太さを2に設定
      contour.draw(); // 輪郭線を描画 
      Contour c=contours.get(i); 
      Rectangle b=c.getBoundingBox();
      box=contour.getBoundingBox();      //輪郭線の外接矩形の情報を獲得
      if (contour.area() > 1000 && a > dist(b.x,b.y,box.x,box.y)) {
          stroke(500,1000,1000);
          ellipse((float)(box.x+box.width/2), (float)(box.y+box.height/2),1,1); //輪郭の中心を特定
          a = dist(b.x,b.y,box.x,box.y);
      }
      if(i>1){
          k = 1;
      }
    }
}

void startmanager(){
    stroke(0,0,0);
    Startbutton(); //スタートボタンの実装
    Contourbutton(); //輪郭ボタンの実装
    fill(0,0,0);
    textAlign(CENTER,CENTER);
    textSize(30);

    text("Breakout Game", 640/2, 100); //ゲームタイトル
    
    textAlign(CENTER,CENTER);
    textSize(18);

    text("Start Game", 640/2, 300); //スタートボタンの文字表示
    text("Contour Setting", 640/2, 400); //輪郭ボタンの文字表示
}

void Startbutton(){
    fill(300,1000,1000);
    if((320-75<=mouseX)&&(320+75>=mouseX)&&(300+40>=mouseY)&&(300-40<=mouseY))
    {
        fill(200,500,1000); //マウスカーソルと重なったら色が変化する
        if(mousePressed == true){
            game = 1;
            for(int i=0;i<8;i++){
                for(int j=0;j<6;j++){
                  is_alive[i][j] = true;
                }
              }
        }
        if(game == 1){ //ゲームの初期化開始
            scene = 1;
            S=true;
        }
        
    }
    rect(320,300,150,80); 
    
}

void Contourbutton(){
    fill(300,1000,1000);
    if((320-75<=mouseX)&&(320+75>=mouseX)&&(400+40>=mouseY)&&(400-40<=mouseY))
    {
        fill(200,500,1000); //マウスカーソルと重なったら色が変化する
        if(mousePressed == true){
            S=true;
        }
    }
    rect(320,400,150,80);  
    
}

void gamecontroller(){
    stroke(0,0,0);
      fill(50,1000,1000);
      ellipse(ball_x, ball_y,ball_r ,ball_r);
      if((keyPressed == true)){gamestart=1;}
      if(gamestart==1) //キーボードが押されたらゲーム開始
      {
          ball_x += speed_x;
          ball_y += speed_y;
      }
      
      if(ball_x+ball_r/2 > 640) speed_x *= -1;
      if(ball_x-ball_r/2 < 0) speed_x *= -1;
      if(ball_y - ball_r/2 <0) speed_y *= -1;
      stroke(0,0,0);
          fill(300,1000,1000);
          x = (float)(box.x+box.width/2);
          rect(x, 400, bar_w, bar_h);
      
      if((ball_x + ball_r/2 > x && ball_x - ball_r/2 < x+bar_w) 
        &&(400 < ball_y + ball_r/2 && ball_y + ball_r/2 < 400+bar_h)){
          speed_y *= -1;
      }
      if(ball_y>height){ //画面の下にボールが落ちた時
          life--;
          ball_x=250;
          ball_y=350;
          gamestart=0;
          speed_x = 3;
          speed_y = -6;
      }
      if(life==0){ //ライフが0になった時
          scene=0;
          gamestart=0;
          S=false;
          game=0;
          score = 0;
          life = 3;
      }
  for(int j=0;j<6;j++){
    for(int i=0;i<8;i++){
      // 生きていればブロックを描画する
      if(is_alive[i][j]==true){
        stroke(0,0,0);
        colorchange(j);
        rect(i*block_w+32, j*block_h+30, block_w, block_h);
      }
      if((ball_x + ball_r/2 > i*block_w && ball_x - ball_r/2 < (i+1)*block_w) 
        &&(j*block_h < ball_y - ball_r/2 && ball_y - ball_r/2 < (j+1)*block_h)
        && is_alive[i][j] ==true){ //条件式に「生きていれば」を追加
          speed_y *= -1;
          ball_y = ball_r/2 + (j+1)*block_h+1;
          is_alive[i][j] = false; // ブロックは消えた
          score += 50;
      }
    }
  }
}

void colorchange(int i){ //ブロックをカラフルにする関数
    if(i == 0){fill(250,1000,1000);}
    else if(i == 1){fill(0,1000,1000);}
    else if(i == 2){fill(80,1000,1000);}
    else if(i == 3){fill(350,1000,1000);}
    else if(i == 4){fill(400,1000,1000);}
    else if(i == 5){fill(460,1000,1000);}
}