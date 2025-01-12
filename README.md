# Fotobox
Installation of the Backend:
Steps:
  1. Backend packagen mit maven
  2. Jar-File aus target-Ordner extrahieren
  3. Jar-File an gewünschte stelle legen
  4. application.properties Datei anlegen mit eigenen Konfigurationen
  5. Jar-File ausführen mit properties Datei


1: Jar-File mit folgendem Befehl aus dem Backend Ordner ausführen:
mvn clean package

2-3: Nach gewünschtem Ergebnis selber anpassen
  
4: application.properties Datei anlegen oder vorhandene Kopieren.
Original befindet sich unter fotobox_backend/src/resources/application.properties

Konfigurationen:
```
spring.application.name=fotobox
folder.path=C:/Users/Herrf/Pictures/TestBilder #Ordner zu images
file.type=jpeg
session.ip=localadress #SessionIP für den QR-Code "localadress" führt dazu, dass die Applikation nach der internen InetAdress sucht
cryption.key=test #SecurityKey für die Verbindung mit dem Frontend
admin.username=admin #Username für Weblogin
admin.password=admin #Passwort für Weblogin
spring.thymeleaf.cache=false
spring.thymeleaf.prefix=classpath:/templates/
spring.thymeleaf.suffix=.html
spring.thymeleaf.mode=HTML5
spring.thymeleaf.encoding=UTF-8
```

5: Jar ausführen mit folgendem Befehl zum einbinden der Konfiguration
java -jar <FILE.jar> --spring.config.location=<PATH to application.properties>

## Create a release
To create a release, push a tag to the repository.
```sh
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0
```

## Run with docker
Use the docker-compose.yml file in the deploy folder to run the backend and frontend.

### Backend
```sh
docker build -t fotobox_backend .
docker run -p 8080:8080 fotobox_backend
```

### Frontend
```sh
docker build -t fotobox_frontend .
docker run -p 8080:80 fotobox_frontend
```
