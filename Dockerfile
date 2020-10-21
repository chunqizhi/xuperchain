FROM golang:1.12.5 AS builder
RUN apt update
WORKDIR /go/src/github.com/xuperchain/xuperunion
COPY . .
RUN make
RUN cd output && ./xchain-cli createChain

# ---
FROM ubuntu:latest
RUN apt-get update && apt-get install -yq gcc
WORKDIR /home/work/xuperunion/
VOLUME /home/work/xuperunion/conf
COPY --from=builder /go/src/github.com/xuperchain/xuperunion/output/ .
COPY --from=builder /go/src/github.com/xuperchain/xuperunion/core/contractsdk/cpp/build/group_chain.wasm .
EXPOSE 37101 47101
ENTRYPOINT ["./xchain"]
