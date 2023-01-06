FROM alpine:latest
ENV DEBIAN_FRONTEND=noninteractive \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:/opt/openvscode-server/bin:/usr/local/bin:/home/workspace/.cargo/bin/:/home/workspace/opt/bin:$PATH \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    EDITOR=code \
    USER=root \
    VISUAL=code \
    GIT_EDITOR="code --wait" \
    OPENVSCODE_SERVER_ROOT=/opt/openvscode-server

RUN apk --no-cache add ca-certificates tar git curl wget libc6-compat g++ cmake gcc make jq libc6-compat gcompat  nodejs-current icu-data-full npm openssl-dev pkgconf perl python3 nano ncdu && \
update-ca-certificates && \
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile default --component rust-src && \
rustup target add \
arm-linux-androideabi \
armv7-linux-androideabi \
aarch64-linux-android \
x86_64-apple-darwin \
aarch64-apple-darwin \
aarch64-linux-android \
i686-linux-android \
wasm32-unknown-unknown \
wasm32-wasi && \
    mkdir /vscode_tmp && \
	cd /vscode_tmp && \
	(curl -s https://api.github.com/repos/gitpod-io/openvscode-server/releases/latest | jq -r ".assets[] | select(.name | contains(\"x64\")) | .browser_download_url"  | wget -i -) && \
	tar xvfz *tar.gz && \
	rm -rf *tar.gz && \
	mv * /opt/openvscode-server
WORKDIR /home/workspace
ENV HOME=/home/workspace \
    USER=workspace

USER 1000:1000
#token in url = tkn
ENTRYPOINT openvscode-server --host ${OPENVSCODE_HOST} --without-connection-token
# --connection-token ${OPENVSCODE_TOKEN}
