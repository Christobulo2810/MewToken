from moviepy.editor import ImageClip, CompositeVideoClip
from moviepy.video.fx.fadein import fadein
from moviepy.video.fx.fadeout import fadeout

# Duración del clip en segundos
duracion = 5  

# Cargar imagen y configurar duración y tamaño
gato = ImageClip("gato_misterioso.png").set_duration(duracion).resize(height=300)

# Aplicar efectos de aparición y desaparición correctamente
gato = fadein(gato, 2)
gato = fadeout(gato, 2)

# Crear un video compuesto con el clip del gato
video = CompositeVideoClip([gato])

# Exportar el video
video.write_videofile("video_gato.mp4", fps=24)

