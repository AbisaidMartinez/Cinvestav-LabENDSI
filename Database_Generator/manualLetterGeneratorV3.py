import cv2
import numpy as np
import os
import random

# Parámetros
canvas_size = (200, 200)  # Tamaño del lienzo
save_path = r'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\a\a_recortes02'  # Carpeta donde se guardarán las imágenes
start_index = 734  # Índice inicial para los nombres de archivo
brush_mode = "solid"  # Modo de pincel inicial
brush_color = (255, 255, 255)  # Color del pincel
brush_thickness = random.randint(2, 30)  # Grosor del pincel inicial

# Crear la carpeta si no existe
if not os.path.exists(save_path):
    os.makedirs(save_path)

# Crear lienzo en blanco
canvas = np.ones((canvas_size[1], canvas_size[0], 3), dtype=np.uint8) * 0

drawing = False  # Flag para dibujar
last_position = None
index = start_index

def draw(event, x, y, flags, param):
    global drawing, last_position, brush_mode, brush_thickness
    
    if event == cv2.EVENT_LBUTTONDOWN:
        drawing = True
        last_position = (x, y)
    elif event == cv2.EVENT_MOUSEMOVE and drawing:
        if last_position is not None:
            if brush_mode == "solid":
                cv2.line(canvas, last_position, (x, y), brush_color, brush_thickness)
            elif brush_mode == "spray":
                for _ in range(10):
                    offset_x = random.randint(-5, 5)
                    offset_y = random.randint(-5, 5)
                    cv2.circle(canvas, (x + offset_x, y + offset_y), 1, brush_color, -1)
            elif brush_mode == "oil":
                cv2.line(canvas, last_position, (x, y), brush_color, brush_thickness)
                blurred = cv2.GaussianBlur(canvas, (5, 5), 2)
                np.copyto(canvas, blurred)
            last_position = (x, y)
    elif event == cv2.EVENT_LBUTTONUP:
        drawing = False
        last_position = None

cv2.namedWindow("Dibuja")
cv2.setMouseCallback("Dibuja", draw)

while True:
    cv2.imshow("Dibuja", canvas)
    key = cv2.waitKey(1) & 0xFF
    
    if key == 13:  # Enter para guardar
        filename = os.path.join(save_path, f"{index}.png")
        cv2.imwrite(filename, canvas)
        print(f"Imagen guardada: {filename}")
        index += 1
        canvas[:] = 0  # Limpiar el lienzo
        brush_thickness = random.randint(2, 20)  # Cambiar grosor solo al iniciar nuevo lienzo
    
    elif key == 27:  # ESC para salir
        break
    
    elif key == ord('1'):
        brush_mode = "solid"
        print("Modo de pincel: Sólido")
    elif key == ord('2'):
        brush_mode = "spray"
        print("Modo de pincel: Aerógrafo")
    elif key == ord('3'):
        brush_mode = "oil"
        print("Modo de pincel: Pintura al óleo")

cv2.destroyAllWindows()
