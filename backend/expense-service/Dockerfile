FROM amazoncorretto:21
WORKDIR /app
COPY backend/jars/expenseService-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 9820
ENTRYPOINT ["java","-jar","app.jar"]
