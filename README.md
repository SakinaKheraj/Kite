# 🪁 Kite — Event-Driven Expense Tracker

A full-stack, event-driven expense tracking platform built using **Spring Boot 3.5**, **FastAPI**, **Apache Kafka**, **MySQL 8.3**, **Docker**, and a cross-platform **Flutter** application.

Kite follows a **microservices architecture**, where services communicate asynchronously through **Apache Kafka**, enabling scalability, loose coupling, and easy extensibility.

---

## ✨ Features

- 🔐 JWT-based Authentication & Authorization
- 👤 User Registration & Profile Management
- 💰 Expense CRUD Operations
- 📊 AI-powered Spending Analytics & Insights
- ⚡ Event-driven communication with Apache Kafka
- 🐳 Docker Compose based deployment
- 📱 Flutter Mobile & Web application
- 🗄️ MySQL 8.3 Database

---

# 🏗️ Project Structure

```text
expense-tracker-app/
├── docker-compose.yml
├── .gitignore
├── README.md
│
├── backend/
│   ├── auth-service/                # Spring Boot (9898)
│   ├── expense-service/             # Spring Boot (9820)
│   ├── user-service/                # Spring Boot (9899)
│   ├── ds-service/                  # FastAPI (8010)
│   └── jars/                        # Docker deployment artifacts
│
└── frontend/
    └── expense_tracker_flutter/     # Flutter application
```

---

# 🛠️ Tech Stack

| Category | Technologies |
|----------|--------------|
| Backend | Spring Boot 3.5, Java 21 |
| AI / Data Service | FastAPI, Python |
| Messaging | Apache Kafka, ZooKeeper |
| Database | MySQL 8.3 |
| Frontend | Flutter |
| Authentication | Spring Security, JWT |
| Containerization | Docker, Docker Compose |
| Build Tool | Gradle |

---

# 🌐 Services

| Service | Port | Responsibility |
|---------|------|----------------|
| **auth-service** | `9898` | User registration, login, password hashing, JWT generation |
| **expense-service** | `9820` | Expense CRUD operations, categories, budgets |
| **user-service** | `9899` | User profile management and Kafka event consumer |
| **ds-service** | `8010` | AI insights, analytics, forecasting |
| **MySQL** | `3306` | Persistent data storage |
| **Kafka** | `9092`, `9094` | Event broker |
| **ZooKeeper** | `2181` | Kafka coordination |

---

# 🔐 Environment Variables

Create a `.env` file in the project root.

```env
# AI Configuration
MISTRAL_API_KEY=your_mistral_api_key

# MySQL Configuration
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_USER=your_database_user
MYSQL_PASSWORD=your_database_password
```
---

# 📡 API Example

## Register User

**Endpoint**

```http
POST /auth/v1/signup
```

**Base URL**

```
http://localhost:9898
```

### Request Body

```json
{
  "username": "demo_user",
  "first_name": "John",
  "last_name": "Doe",
  "email": "john.doe@example.com",
  "phone_number": "9876543210",
  "password": "Password123!"
}
```

### Validation Rules

| Field | Validation |
|------|-------------|
| Email | Valid email format |
| Password | Minimum 6 characters including uppercase, lowercase, digit, and special character |

---

# 🔄 Event Flow

```text
                        POST /signup
                              │
                              ▼
                     +----------------+
                     | auth-service   |
                     +----------------+
                              │
                   Publish UserInfoEvent
                              │
                              ▼
                      +----------------+
                      |     Kafka      |
                      +----------------+
                         │          │
                Consume  │          │  Consume
                         ▼          ▼
                +---------------+  +------------------+
                | user-service  |  | expense-service  |
                +---------------+  +------------------+
                | Create User   |  | Initialize User  |
                +---------------+  +------------------+
```

---

# 🚀 Getting Started

## 1. Clone the Repository

```bash
git clone <repository-url>

cd expense-tracker-app
```

---

## 2. Configure Environment Variables

Create a `.env` file in the project root.

```env
MISTRAL_API_KEY=your_api_key

MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_USER=your_database_user
MYSQL_PASSWORD=your_database_password
```

---

## 3. Build Spring Boot Services

Navigate to each Spring Boot service.

```powershell
cd backend/auth-service

.\gradlew clean build -x test
```

Repeat for:

- auth-service
- expense-service
- user-service

Copy each generated JAR into the `backend/jars` directory (or configure your Dockerfiles accordingly).

---

## 4. Start All Services

```bash
docker compose up -d --build
```

Verify running containers.

```bash
docker ps
```

View logs.

```bash
docker logs -f auth-service
```

---

## 5. Database Verification

View registered users.

```bash
docker exec -it mysql-8.3.0 \
mysql -u root -p"<YOUR_ROOT_PASSWORD>" \
-e "USE authservice; SELECT * FROM users;"
```

Clear user records.

```bash
docker exec -it mysql-8.3.0 \
mysql -u root -p"<YOUR_ROOT_PASSWORD>" \
-e "USE authservice; TRUNCATE TABLE users;"
```

---

## 6. Run the Flutter Application

```bash
cd frontend/expense_tracker_flutter

flutter pub get

flutter run
```

---

# 📦 Architecture

```text
                     Flutter Application
                              │
                              ▼
                      auth-service (JWT)
                              │
               ┌──────────────┴──────────────┐
               ▼                             ▼
            Kafka Topic                REST APIs
               │
       ┌───────┴────────┐
       ▼                ▼
 user-service     expense-service
                         │
                         ▼
                   ds-service (FastAPI)
                         │
                         ▼
                      MySQL 8.3
```

---

# 📌 Future Improvements

- Google OAuth Authentication
- Email Verification
- Budget Notifications
- Receipt OCR
- AI-based Expense Categorization
- Monthly Financial Reports
- Kubernetes Deployment
- GitHub Actions CI/CD Pipeline
- Grafana & Prometheus Monitoring

---
