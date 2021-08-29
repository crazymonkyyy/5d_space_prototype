import raylib;
enum windowx=800;
enum windowy=600;
enum velfactor=0.001;
struct circle{
	int x;
	int y;
	int r;
	bool collision(circle a){
		import raymath;
		return (r+a.r)>Vector2Distance(Vector2(x,y),Vector2(a.x,a.y));
	}
}
bool collisions(T)(circle a,T array){
	foreach(e;array){
		if(e.collision(a)){return true;}
	}
	return false;
}
struct bullet_{
	float x; float xv;
	float y; float yv;
	int   t; float toffset; float tv;
	int   d; float doffset; float dv;
	int payload;
	bool explode=false;
	circle me(){
		import std.conv;
		return circle(x.to!int,y.to!int,10);
	}
	circle meexploded(){
		import std.conv;
		return circle(x.to!int,y.to!int,50);//todo
	}
	void updatephysical(T)(circle[] planets,T craters){
		x+=xv*velfactor;
		y+=yv*velfactor;
		x%=windowx;
		y%=windowy;
		//todo gravity
		explode|=me.collisions(planets) && ! me.collisions(craters);
	}
	void updatetimeline(alias spacetimeexists)(){
		void manage(ref int litteral,ref float offset,ref float velosity){
			int oldlit=litteral;
			offset+=velosity;
			if(offset>1){
				++litteral;offset-=1;
			}
			if(offset<-1){
				--litteral;offset+=1;
			}
			if( ! spacetimeexists(t,d)){
				litteral=oldlit;
				velosity=-velosity;
			}
		}
		manage(t,toffset,tv);
		manage(d,doffset,dv);
	}
}
void main(){
	import std.string;
	import std.random;
	InitWindow(windowx, windowy, "Hello, Raylib-D!");
	SetWindowPosition(2000,0);
	SetTargetFPS(60);
	circle[] planets;
	Color[] planetcolors;
	import treegrid_;
	treegrid!circle craters;
	circle[] stars;
	circle[6] players;
	bullet_ bullet;
	//float x; float xv;
	//float y; float yv;
	//int   t; float toffset; float tv;
	//int   d; float doffset; float dv;
	with(bullet){
		x=0; y=0;
		xv=3000;yv=6000;
		toffset=0; tv=.003;
		doffset=0; dv=.01;
	}
	int curtime;
	int curspace;
	auto currentcraters(){
		return craters[curtime,curspace].past;
	}
	bool spacetimeexists(int i, int j){
		return (loc(i,j) in craters.data)!is null;
	}
	
	Texture2D[4][2] spite;
	foreach(i,color;["red","blue"]){
	foreach(j,num;["1","2","3"]){
		spite[i][j]=LoadTexture(toStringz("spites/playerShip"~num~"_"~color~".png"));
	}}
	spite[1][3]=LoadTexture("spites/ufoBlue.png");
	spite[0][3]=LoadTexture("spites/ufoRed.png");
	foreach(i;1..50){
		stars~=circle(uniform(0,windowx),uniform(0,windowy),uniform(1,3));
		planets~=circle(uniform(0,windowx),uniform(0,windowy),uniform(40,80));
		planetcolors~=Color(cast(ubyte)uniform(125,255),cast(ubyte)uniform(125,255),cast(ubyte)uniform(125,255),255);
	}
	craters.data[loc(0,0)]=circle(0,0,0);
	craters[0,0]~=circle(400,300,100);
	craters[0,0]~=circle(200,300,100);
	craters[1,0]~=circle(600,300,100);
	foreach(i;0..6){
		players[i]=circle(uniform(0,windowx),uniform(0,windowy),10);
	}
	void drawmainview(bool active=false,T)(T craters,string message){
		BeginDrawing();
		DrawText(message.toStringz, 10, 10, 28, Colors.WHITE);
		ClearBackground(Colors.BLACK);
			foreach(i,e;planets){
				DrawCircle(e.x,e.y,e.r,planetcolors[i]);
			}
			foreach(e;currentcraters){
				DrawCircle(e.x,e.y,e.r,Colors.BLACK);
			}
			foreach(ref e;stars){
				if(e.collisions(currentcraters)|| ! e.collisions(planets)){
					DrawCircle(e.x,e.y,e.r,Colors.YELLOW);
				}
				e.x+=1;
				e.x%=windowx;
			}
			foreach(i,ref e;players){
				int ship=i%3;
				if(e.collisions(currentcraters)){
					ship=3;
				}
				//DrawTexture(spite[i/3][i%3],e.x-45,e.y-45,Colors.WHITE);
				DrawTextureEx(spite[i/3][ship],Vector2(e.x-10,e.y-10),0,2.0/9,Colors.WHITE);
			}
			static if(active){ with(bullet.me){
				DrawCircle(x,y,r,Colors.WHITE);
			} }
			DrawFPS(windowx-30,windowy-30);
			DrawText(message.toStringz, 10, 10, 28, Colors.WHITE);
		EndDrawing();
	}
	void drawstatic(){
		BeginDrawing();
		foreach(x;0..windowx){
		foreach(y;0..windowy){
			DrawPixel(x,y,uniform(0,2) ? Colors.BLACK:Colors.WHITE);
		}}
		EndDrawing();
	}
	//while (!WindowShouldClose()){
	//	foreach(i;0..60){drawmainview(currentcraters,"bad timeline");}
	//	foreach(i;0..5 ){drawstatic();}
	//	foreach(i;0..60){drawmainview!(true,circle[])([],"year 0");}
	//	foreach(i;0..5 ){drawstatic();}
	//	import std;
	//}
	while (!WindowShouldClose()){
		bullet.updatephysical(planets,currentcraters);
		bullet.updatetimeline!spacetimeexists;
		if(IsKeyPressed(KeyboardKey.KEY_SPACE)){
			craters[curtime,curspace]~=bullet.meexploded;
		}
		
		bool timelineshift=false;
		if(bullet.t!=curtime){curtime=bullet.t;timelineshift|=true;}
		if(bullet.d!=curspace){curspace=bullet.d;timelineshift|=true;}
		if(timelineshift){
			foreach(i;0..6){drawstatic;}
		}
		import std.conv;
		string localstring="current space time:"~curtime.to!string~","~curspace.to!string;
		drawmainview!true(currentcraters,localstring);
	}
	CloseWindow();
}