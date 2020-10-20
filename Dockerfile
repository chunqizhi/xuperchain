FROM golang:1.12.5 AS builder
RUN apt update
WORKDIR /go/src/github.com/xuperchain/xuperunion
COPY . .
RUN make
RUN cd output && ./xchain-cli createChain

# ---
FROM ubuntu:latest
WORKDIR /home/work/xuperunion/
VOLUME /home/work/xuperunion/conf
COPY --from=builder /go/src/github.com/xuperchain/xuperunion/output/ .
EXPOSE 37101 47101
ENTRYPOINT ["./xchain"]
