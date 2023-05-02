import cv2
import time
import socket
import time

#client 发送端
client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
PORT = 8001


CONFIDENCE_THRESHOLD = 0.5
NMS_THRESHOLD = 0.4
COLORS = [(0, 255, 255), (0, 0, 255), (125, 255, 0), (100, 200, 0), (0, 0, 255)]

class_names = []
with open("classes.txt", "r") as f:
    class_names = [cname.strip() for cname in f.readlines()]

vc = cv2.VideoCapture(0)

net = cv2.dnn.readNet("yolov4-tiny-custom_best.weights", "yolov4-tiny-custom.cfg")
net.setPreferableBackend(cv2.dnn.DNN_BACKEND_CUDA)
net.setPreferableTarget(cv2.dnn.DNN_TARGET_CUDA_FP16)

model = cv2.dnn_DetectionModel(net)
model.setInputParams(size=(416, 416), scale=1/255, swapRB=True)

while cv2.waitKey(1) < 1:
    (grabbed, frame) = vc.read()
    if not grabbed:
        exit()

    start = time.time()
    classes, scores, boxes = model.detect(frame, CONFIDENCE_THRESHOLD, NMS_THRESHOLD)
    end = time.time()

    start_drawing = time.time()
    for (classid, score, box) in zip(classes, scores, boxes):
        color = COLORS[int(classid) % len(COLORS)]
        label = "%s : %f" % (class_names[classid], score)
        cv2.rectangle(frame, box, color, 2)
        msg=str(box[0]+int(box[2]/2))+","+str(box[1]+int(box[3]/2))+","+str(classid)
        print(box,msg,classid)
        server_address = ("127.0.0.1", PORT)  # 接收方 服务器的ip地址和端口号
        client_socket.sendto(msg.encode(), server_address) #将msg内容发送给指定接收方
        cv2.putText(frame, label, (box[0], box[1] - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
    end_drawing = time.time()
    
    fps_label = "FPS: %.2f (excluding drawing time of %.2fms)" % (1 / (end - start), (end_drawing - start_drawing) * 1000)
    cv2.putText(frame, fps_label, (0, 25), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 0), 2)
    cv2.imshow("detections", frame)
vc.release()
cv2.destroyAllWindows()
