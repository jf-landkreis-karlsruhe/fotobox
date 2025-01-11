# Use the official Dart image to run the build
FROM dart:stable AS build

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Set the working directory
WORKDIR /app

# Copy the pubspec files and download dependencies
COPY pubspec.* ./
RUN flutter pub get

# Copy the rest of the application files
COPY . .

# Enable web support and build the Flutter web application
RUN flutter config --enable-web
RUN flutter build web

# Use an Nginx image to serve the Flutter web application
FROM nginx:stable-alpine

# Copy the built web files to the Nginx html directory
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80 to the outside world
EXPOSE 80

# Start Nginx server
# Create entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
