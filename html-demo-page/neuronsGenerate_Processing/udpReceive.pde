void receive( byte[] data, String ip, int port ) {  // <-- extended handler

  data = subset(data, 0, data.length);
  String message = new String( data );
  if (message!=null) {
    String[] cor=message.split(",");
    println(message);
    printArray(cor);
    if (cor.length==3) {
      float Px=map(parseInt(cor[0]), 0, 640, 0, width);
      float Py=map(parseInt(cor[1]), 0, 480, 0, height);
      PVector posTemp=new PVector(Px, Py);
      int type=parseInt(cor[2]);
      boolean stableNow=false;
      for (int i=0; i<stablePt.size(); i++) {
        PVector tempP=stablePt.get(i);
        if (posTemp.dist(tempP)<150) {
          stableNow=true;
        }
      }
      if (stableNow==false) {
        boolean newCom=true;
        for (int i=0; i<ptAll.size(); i++) {
          newComPoint tempP=ptAll.get(i);
          if (posTemp.dist(tempP.pos)<150) {
            tempP.update(type);
            newCom=false;
          }
        }
        if (newCom) {
          ptAll.add(new newComPoint(Px, Py, type));
        }
      }

      println( Px, Py, type);
    }
  }
}
