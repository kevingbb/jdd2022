# JDD 2022

## Local Setup

1. Open in Codespaces or as a DevContainer in VS Code
2. Start API on http://localhost:8080

```bash
# Run Spring Boot API App
cd /workspace/api
./mvnw spring-boot:run
```

3. Start UI on http://localhost:8081

```bash
# Run VueJS SPA
cd /workspace/ui
npm install
npm run serve
```

### Build Containerized Versions if Desired

```bash
# Build Spring Boot API Container Image
cd /workspace/api
./mvnw clean install spring-boot:repackage
docker build -t jdd2022/api:v1 .
# Run & Test Container Image Locally
docker run -it --rm -p 8080:8080 --name jdd2022-api --network=host -e="SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/javaspringtest" jdd2022/api:v1
```

```bash
# Build Vue UI Container Image
cd /workspace/ui
docker build -t jdd2022/ui:v1 .
# Run & Test Container Image Locally
docker run -it --rm -p 8081:1025 --name jdd2022-ui jdd2022/ui:v1
```
