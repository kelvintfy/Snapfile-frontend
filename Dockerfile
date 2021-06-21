# FROM alexttyip/flutter as flutter_build
# COPY --chown=user . .
# RUN flutter build web
# FROM nginx:alpine
# WORKDIR /usr/share/nginx/html
# COPY --from=flutter_build /home/user/build/web/ .

