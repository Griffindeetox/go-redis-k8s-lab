# Step 1: Build stage
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -o app main.go

# Step 2: Run stage
FROM alpine:3.18

WORKDIR /app
COPY --from=builder /app/app .
EXPOSE 8080
CMD ["./app"]
