from flask import Flask, request, jsonify
import os
from flask_cors import CORS
import base64, cv2

from ultralytics import RTDETR
from PIL import Image
import matplotlib.pyplot as plt

app = Flask(__name__)
MODEL = RTDETR("last.pt")
CORS(app, resources={r"/*": {"origins": "*"}})

def run_inference(image_path: str, acc: int):
    results = MODEL.predict(source=image_path, imgsz=512, conf=acc)
    result = results[0]




    img_with_boxes = result.plot()
    ok, buf = cv2.imencode('.jpg', img_with_boxes)    # JPEG в память
    img_b64 = base64.b64encode(buf.tobytes()).decode('ascii')

    output = []
    for box in result.boxes:
        cls_idx = int(box.cls[0].item() if hasattr(box.cls[0], "item") else int(box.cls[0]))
        conf = float(box.conf[0].item() if hasattr(box.conf[0], "item") else float(box.conf[0]))
        output.append({
            "class_id": cls_idx,
            "class_name": result.names[cls_idx] if hasattr(result, "names") else str(cls_idx),
            "confidence": conf
        })
    return output, img_b64

OUTPUT_PATH = 'predicted.jpg'
UPLOAD_FOLDER = 'uploads/'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

def predict():
    # 3 Берём файл из request

    file = request.files.get("image")
    note = request.form.get('note')
    if not file or file.filename == "" or not note or note == "":
        return jsonify({"error": "no file/note uploaded"}), 400
    
    

    file_path = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(file_path)

    try:
        preds = run_inference(file_path, int(note)/100)
        return jsonify({"predictions": preds[0], "img": preds[1]}), 200
    except Exception as e:
        app.logger.exception("inference failed")
        return jsonify({"error": str(e)}), 500
    finally:
        # чистим файл
        try:
            os.remove(file_path)
        except Exception:
            pass

# Если хочешь отдельный /upload, он может просто вызывать run_inference так же
@app.route("/upload", methods=["POST"])
def upload_image():
    return predict()



if __name__ == '__main__':
    app.run(debug=True)
