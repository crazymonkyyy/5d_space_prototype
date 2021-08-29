struct loc{
	int x;
	int y;
	auto opBinary(string s:"+")(int i){
		return loc(x+i,y);
	}
}
struct treegrid(T){
	T[loc] data;
	loc[loc] spilts;
	int next=1;
	auto opIndex(int x,int y){
		struct node{
			loc me;
			treegrid!T* parent_; auto ref parent(){return *parent_;}
			ref T get(){
				return parent.data[me];
			}
			alias get this;
			void opOpAssign(string s:"~")(T next){
				if( me+1 !in parent.data){
					parent.data[me+1]=next;
				} else {
					auto spilt=loc(me.x+1,parent.next);parent.next++;
					parent.data[spilt]=next;
					parent.spilts[spilt]=me;
				}
			}
			node pastnext(){
				if( me+-1 in parent.data){
					return node(me+-1,parent_);
				}else{
					return node(parent.spilts[me],parent_);
				}
			}
			auto past(){
				struct range{
					node me;
					void popFront(){
						me=me.pastnext;}
					T front(){
						return me.get;}
					bool empty(){
						return me.me==loc(0,0);
					}
				}
				return range(this);
			}
		}
		return node(loc(x,y),&this);
	}
}
unittest{
	treegrid!int hi;
	hi.data[loc(0,0)]=3;
	import std;
	int(hi[0,0]).writeln;
	hi[0,0]~=4;
	int(hi[1,0]).writeln;
	hi[0,0]~=5;
	int(hi[1,0]).writeln;
	int(hi[1,1]).writeln;
	hi[1,1]~=6;
	hi[2,1].past.writeln;
}