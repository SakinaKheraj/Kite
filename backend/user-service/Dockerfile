FROM amazoncorretto:21
WORKDIR /app
COPY backend/jars/userservice-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 9899
CMD ["java", "-jar", "app.jar"]
