# --- Stage 1: Downloader ---
FROM alpine:latest AS downloader
RUN apk add --no-cache curl unzip

WORKDIR /download

# Fetch latest Xray release
RUN LATEST=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest \
    | grep tag_name | cut -d '"' -f 4) && \
    curl -L "https://github.com/XTLS/Xray-core/releases/download/${LATEST}/Xray-linux-64.zip" -o xray.zip && \
    unzip xray.zip

# --- Stage 2: Runtime ---
FROM alpine:latest

RUN apk add --no-cache ca-certificates tzdata bash

WORKDIR /app

COPY --from=downloader /download/xray .
COPY config.json .

RUN chmod +x xray

EXPOSE 8080

CMD ["./xray", "-config", "config.json"]
