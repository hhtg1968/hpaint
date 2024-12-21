//
// hPaint1 (c) hhtg. 2020-2022
//
// v1.3.1.0 mac-pc-linux-(IOS) 26.11.2022 18h47 - bug found! menu is now correct when changing stroke >=4!
//
// 1-FensterVersion! iPad
//
// to do:
//
// new: del grey as subR
//

int t,t1,mm,mw=-4144960,mw1=-8421505,mw2=-9474193,black=-16777216,sp,lx,lx1,ly,ly1;
short c=0,bc=192,st=1,sw=2,x,y,fxl,fxr,res_x=720,res_y=576,old_x=-1,old_y,by;// short= 16bit int!
short stackx[],stacky[],framenr=0,maxfr=127,upfr=0,pfr=0,n,m;//upfr - highest used frame
byte fs=0,ol=0,os=0,modus=0,cont=1,spd=1,ch=0,flg,cmd=0,fflag=1;//ch - flag for change
String fname="image.png",mname[];
PImage dscreen,sframe[];


void setup()
{
  size(804,576);// PAL resolution720+84(menu)?! just for fun
  stackx=new short[res_x*res_y];// software stack for fill
  stacky=new short[res_x*res_y];
  mname=new String[4];
  mname[0]="draw";
  mname[1]="fill";
  mname[2]="line";
  mname[3]="";
  sframe=new PImage[128];
  dscreen=createImage(res_x,res_y,RGB);
  image(dscreen,0,0);
  initscr();
  t=millis();
  noSmooth();//turn off antialiasing
}

void draw()//{if(mousePressed=false){
{
  fflag=1;
  if(mousePressed==true && mouseX<res_x)
  {
    t1=millis();
    if(t1-t<128)// only draw if there was no long pause (1/8s) to last draw
    {
      if(mouseButton==LEFT && modus==0)
      {
        stroke(c);// paint
      }
      if(mouseButton==RIGHT && modus==0)
      {
        stroke(bc);// erase
      }
      lx=mouseX;lx1=pmouseX;ly=mouseY;ly1=pmouseY;
      if(lx<res_x)
      {
        if(lx1>=res_x){lx1=res_x;}
        line(lx,ly,lx1,ly1);
      }// do not paint into menu!
      t=millis();
      old_x=(short)mouseX;
      old_y=(short)mouseY;
      stroke(c);
    } 
    else
    {t=millis();}
  }// drawing...
  if(cont==1)// every round of the draw method needs a key release exept for draw by mouse
  {
  if(keyPressed==true && key==99)//"c"
  {
    initscr();
    cont=0;
  } // clear screen by key
  if(keyPressed==true && key==105 && cmd==0 && mouseX<res_x)// "i"
  {
    strokeWeight(1);
    print("recent point col: ");println(get(mouseX,mouseY));
    strokeWeight(sw*st+1);
    cont=0;
  }// show color by key to console
  if((keyPressed==true && key==102)||((mouseButton==LEFT && modus==1) && cmd==0 && mouseX<res_x && fflag==1))//fill modus or "f"
  {
    x=(short)mouseX;
    y=(short)mouseY;
    cont=0;
    floodfill();
    //while(mousePressed){}
    fflag=0;
    //cont=0;
    //cmd=?
  }// floodfill by key or klick!
  if(keyPressed==true && key==109)//"m"
  {
    modus++;
    if(modus==3){modus=0;}
    if(modus==2){old_x=-1;}// line modus starts
    cont=0;
  }// change modus by key
  if(keyPressed==true && key==115)//"s"
  {
    saveanim();
    cont=0;
    ch=0;
  } // save img/anim by key
  if(keyPressed==true && key==111)//"o"
  {
    openanim();
    cont=0;
  }// load img by key
  if((keyPressed==true && key==103) || cmd==4)// "g" or klick
  {
    del_grey();
    cont=0;
    cmd=0;
  }// grey erased by key or klick
  if((keyPressed==true && key==43) || cmd==1)// "+"
  {
  {
    del_grey();
    cont=0;
    }
    strokeWeight(1);
    save("tmp.png");
    sframe[framenr]=loadImage("tmp.png");
    framenr++;
    if(framenr>maxfr)
    {
      framenr=maxfr;println("max frame...");
    }
    else
    {
    print("... frame inc: ");println(framenr);
    if(upfr<framenr)
    {
      println("new frame...");
      upfr++;
      stroke(127);// grey
      for(n=0;n<720;n++)
      {
        for(m=0;m<576;m++)
        {
          mm=get(n,m);
          if(mm==black)
          {
            point(n,m);
          }
        }
      }
      println("image greyscaled...");
      save("tmp.png");
      sframe[framenr]=loadImage("tmp.png");
      strokeWeight(sw*st+1);
    }
    }
    image(sframe[framenr],0,0);
    stroke(c);
    cont=0;
    cmd=0;
  }// + inc frame number by key or klick
  if((keyPressed==true && key==45) || cmd==2)// "-"
  {
    save("tmp.png");
    dscreen=loadImage("tmp.png");
    sframe[framenr]=dscreen;
    framenr--;
    if(framenr<0)
    {
      framenr=0;
      println("first frame...");
    }
    else
    {
      print("... frame dec: ");println(framenr);
    }
    dscreen=sframe[framenr];
    image(dscreen,0,0);
    cont=0;
    cmd=0;
  }// - dec frame number by key or klick
  if((keyPressed==true && key==112) || cmd==3)//"p"
  {
    save("tmpa.png");
    sframe[framenr]=loadImage("tmpa.png");
    cont=2;
    cmd=0;
    println("playing anim...");
  }// show animation by key or klick
  if(keyPressed==true && key==113)//"q"
  {
    if(ch==0)
    {
      endapp();
    }
  }//"quit" by key
  if((keyPressed==true && key==108)||(mouseButton==LEFT && modus==2) && cmd==0 && mouseX<res_x)//line modus or "l"
  {
    if(old_x==-1)
    {
      old_x=(short)mouseX;
      old_y=(short)mouseY;
    }
    else
    {
      line(old_x,old_y,mouseX,mouseY);
      old_x=(short)mouseX;
      old_y=(short)mouseY;
      cont=0;
    }
  }// draw line by key or klick
  if(keyPressed==true && key>=48 && key<=57)//"0"..."9"
  {
    st=(short)(key-48);
    cont=0;
  }// change weight of stroke by key
  strokeWeight(st*sw+1);
  }
  if(keyPressed!=true && mousePressed!=true && cont<2)
  {
    cont=1;
  }// wait on key/mouse release...
  if(cont==1 && mousePressed==true && mouseX>res_x && mouseY>res_y-160)
  {
    st=(short)((mouseY-160)/16-16);
    strokeWeight(sw*st+1);
    print("stroke: ");println(st);
    cont=0;
  }// set stroke by klick
  if(cont==1 && mousePressed==true && mouseX>res_x && mouseY<res_y-176 && mouseY>res_y-192)
  {
    endapp();
  }// quit by klick
  if(cont==1 && mousePressed==true && mouseX>res_x && mouseY<res_y-192 && mouseY>res_y-208)
  {
    initscr();
    cont=0;
  }// cls by klick
  if(cont==1 && mousePressed==true && mouseX>res_x && mouseY<res_y-176-7*16 && mouseY>res_y-192-7*16)
  {
    modus=2;
    old_x=-1;
    cont=0;
    println("line mode");
  }// line mode by klick
  if(cont==1 && mousePressed==true && mouseX>res_x && mouseY<res_y-176-8*16 && mouseY>res_y-192-8*16)
  {
    modus=1;
    cont=0;
    println("fill mode");
  }// fill mode by klick
  if(cont==1 && mousePressed==true && mouseX>res_x && mouseY<res_y-176-9*16 && mouseY>res_y-192-9*16)
  {
    modus=0;
    cont=0;
    println("draw mode");
  }// draw mode by klick
  if(cont==1 && mousePressed==true && mouseX>res_x && mouseX<res_x+42 && mouseY<res_y-176-3*16 && mouseY>res_y-192-3*16)
  {
    cmd=2;
    cont=0;
    println("dec freame");
  }// dec frame by klick
  if(cont==1 && mousePressed==true && mouseX>res_x && mouseX<res_x+84 && mouseY<res_y-176-5*16 && mouseY>res_y-192-5*16)
  {
    cmd=3;
    cont=0;
    println("dec frame");
  }// playA by klick
  if(cont==1 && mousePressed==true && mouseX>res_x+42 && mouseX<res_x+84 && mouseY<res_y-176-3*16 && mouseY>res_y-192-3*16)
  {
    cmd=1;
    cont=0;
    println("inc frame");
  }// inc frameby klick
  if(cont==1 && mousePressed==true && mouseX>res_x && mouseX<res_x+84 && mouseY<res_y-176-13*16 && mouseY>res_y-192-13*16)
  {
    cmd=4;
    cont=0;
    println("erasing grey");
  }// erase grey by klick
  if(cont==2)// playin anim during running "draw"!
  {
    print("... playing frame: ");println(pfr);
    image(sframe[pfr],0,0);
    draw_menu1(); // geht nicht!?
    delay(spd*256);
    pfr++;
    if(pfr>upfr)
    {
      pfr=0;
    }
  }
  if(cont==2 && (key==113 || mousePressed==true ))// "q" or klick to quit anim
  {
    cont=0;
    image(loadImage("tmpa.png"),0,0);
    println("... anim ended");
  }// end anim by key or klick
  draw_menu1();
}

void cls()
{
  background(bc,bc,bc);
  println("... screen cleared");
}// clear screen grey

void endapp()
{
  println("... quitting");
  exit();
}

void initscr()
{
  stroke(c); // 0 zB black
  strokeWeight(sw*st+1);
  fill(0);
  cls();
  old_x=-1;
  draw_menu();
}

void floodfill()
{
  int maxsp=0;
  sp=0;
  if(get(x,y)==mw)
  {
    sp=1;
    strokeWeight(1);
  }
  while(sp>0)
  {
    scanline();
    x=stackx[sp];
    y=stacky[sp];
    if(maxsp<sp){maxsp=sp;}
    sp--;
  }
  strokeWeight(st*sw+1);
  println("... filled");
  print("max sp: ");print(4*maxsp);println(" bytes...");
  //while(mousePressed==true){} führt zum Aufhängen...
  //delay(256);
}

void scanline()
{
  while(get(x,y)==mw)
  {
    fxl=x;
    fxr=(short)(x+1);
    if(fxr>res_x){fxr--;}
    while(fxl>0 && get(fxl,y)==mw)
    {
      if(y>0 && get(fxl,y-1)==mw)
      {
        sp++;
        stackx[sp]=(short)fxl;
        stacky[sp]=(short)(y-1);
      }
      if(y<res_y && get(fxl,y+1)==mw)
      {
        sp++;
        stackx[sp]=(short)(fxl);
        stacky[sp]=(short)(y+1);
      }
      fxl--;
    }
    while(fxr<res_x && get(fxr,y)==mw)
    {
      if(y<res_y && get(fxr,y+1)==mw)
      {
        sp++;
        stackx[sp]=fxr;
        stacky[sp]=(short)(y+1);
      }
      if(y>0 && get(fxr,y-1)==mw)
      {
        sp++;
        stackx[sp]=fxr;
        stacky[sp]=(short)(y-1);
      }
      fxr++;
    }
    line(fxl,y,fxr,y);
  }
}

void openanim()
{
  dscreen=loadImage("image.png");
  image(dscreen,0,0);
  println("... image loaded");
  cont=0;
}

void saveanim()
{
  save("image.png");
  println("... image saved");
  cont=0;
}

void draw_menu()// static menu
{
  stroke(c);
  strokeWeight(2);
  fill(c);
  line(res_x,0,res_x,res_y);
  text("(c)hhtg 2020-22",res_x+4,12);
  line(res_x,18,res_x+84,18);
    for(n=0;n<10;n++)
  {
    text(9-n,res_x+40,res_y-4-n*16);
  }
  text("Quit",res_x+32,res_y-176);
  text("Cls",res_x+32,res_y-176-16);
  text("-frame+",res_x+18,res_y-176-48);
  text("playA",res_x+24,res_y-176-80);
  text("Line",res_x+26,res_y-176-112);
  text("Fill",res_x+26,res_y-176-112-16);
  text("Draw",res_x+26,res_y-176-112-32);
  text("-speed+",res_x+18,res_y-176-112-64);
  text("delGrey",res_x+18,res_y-176-112-96);
  text("save",res_x+28,res_y-176-112-96-32);
  text("load",res_x+28,res_y-176-112-96-48);
  line(res_x,18+64+4,res_x+84,18+64+4);
  strokeWeight(sw*st+1);
}

void draw_menu1()// dynamic menu
{
  by=32;
  stroke(bc);
  strokeWeight(1);
  fill(bc);
  rect(res_x+48,by/2+6,48,56);
  stroke(c);
  fill(c);
  text("mode:",res_x+4,by);text(mname[modus],res_x+50,by);
  text("stroke:",res_x+4,by+16);text(st,res_x+50,by+16);
  text("frame: ",res_x+4,by+32);text(framenr,res_x+50,by+32);
  text("speed:",res_x+4,by+48);text(spd,res_x+50,by+48);
  strokeWeight(sw*st+1);
}

void del_grey()
{
    strokeWeight(1);
    stroke(bc);
    fill(bc);
    flg=0;
    for(n=0;n<res_x;n++)
    {
        for(m=0;m<res_y;m++)
      {
          mm=get(n,m);
          if(mm!=black)// grey? not equal black...
        {
            point(n,m);
            flg=1;
        }
      }
    }
    fill(c);
    if(flg==1){println("grey erased...");}
    else {println("no grey...");}
    strokeWeight(sw*st+1);
}
