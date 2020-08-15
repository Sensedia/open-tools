FROM scratch
# Image base https://hub.docker.com/_/scratch

# Informacoes sobre a imagem
LABEL maintainer="Aécio Pires and Otavio Prado" \
      date_create="14/08/2020" \
      version="1.0.0" \
      description="Specifies the image of the rutil" \
      licensce="MIT License"

COPY bin/rutil rutil

ENTRYPOINT ["./rutil"]