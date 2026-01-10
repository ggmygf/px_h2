# --- Stage 1: Downloader ---
FROM alpine:latest AS downloader
RUN apk add --no-cache curl tar

WORKDIR /download

RUN LATEST_VERSION=$(curl -s https://api.github.com/repos/SagerNet/sing-box/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//') && \
    curl -L "https://github.com/SagerNet/sing-box/releases/download/v${LATEST_VERSION}/sing-box-${LATEST_VERSION}-linux-amd64.tar.gz" -o sb.tar.gz && \
    tar -xzf sb.tar.gz --strip-components=1

# --- Stage 2: Final Runtime ---
FROM alpine:latest

RUN apk add --no-cache ca-certificates tzdata bash

WORKDIR /app

COPY --from=downloader /download/sing-box .
COPY config.json .

RUN chmod +x sing-box

# 🔐 Create a non-root user
RUN adduser -D -u 1000 appuser

# 🔐 Switch to that user
USER appuser

EXPOSE 8080

CMD ["./sing-box", "run", "-c", "config.json"]
