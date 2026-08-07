FROM amazoncorretto:21
WORKDIR /app
COPY backend/jars/app-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 9898
ENTRYPOINT ["java","-jar","app.jar"]
