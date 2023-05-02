class newComPoint {
  int showCount=0;
  int state=0;
  int type=0;
  PVector pos;
  newComPoint(float x, float y, int type) {
    pos=new PVector(x, y);
    this.type=type;
  }
  void update(int tp) {
    if (showCount<10) {
      showCount=showCount+1;
      this.type=tp;
    } else {
      if (state==0) {
        state=1;
        stablePt.add(pos);
        int num=stablePt.size();
        println(num);
        if (num>1) {
          ArrayList<PVector>pathPtList = new ArrayList<PVector>();
          tempPath = new Path();
          tempPath.addPoint(stablePt.get(num-2).x,stablePt.get(num-2).y, 0);
          tempPath.addPoint(stablePt.get(num-1).x,stablePt.get(num-1).y, 0);
          println(stablePt.get(num-2).x,stablePt.get(num-2).y,stablePt.get(num-1).x,stablePt.get(num-1).y);
          pathPtList.addAll(tempPath.getPathPoints());
          cummPathPts.add(pathPtList);
          pathList.add(tempPath);
        }
        ptAll.remove(this);
      }
    }
  }
}
