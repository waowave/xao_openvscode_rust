FROM alpine:latest
ENV DEBIAN_FRONTEND=noninteractive RUSTUP_HOME=/usr/local/rustup CARGO_HOME=/usr/local/cargo PATH=/usr/local/cargo/bin:/opt/openvscode-server/bin:/usr/local/bin:$PATH
RUN apk --no-cache add ca-certificates tar git curl wget libc6-compat g++ cmake gcc make jq libc6-compat gcompat && \
update-ca-certificates
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile complete --component rust-src
RUN mkdir /vscode_tmp && \
	cd /vscode_tmp && \
	(curl -s https://api.github.com/repos/gitpod-io/openvscode-server/releases/latest | jq -r ".assets[] | select(.name | contains(\"x64\")) | .browser_download_url"  | wget -i -) && \
	tar xvfz *tar.gz && \
	rm -rf *tar.gz && \
	mv * /opt/openvscode-server
WORKDIR /home/workspace
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    HOME=/home/workspace \
    EDITOR=code \
    VISUAL=code \
    GIT_EDITOR="code --wait" \
    OPENVSCODE_SERVER_ROOT=/opt/openvscode-server

RUN apk --no-cache add nodejs-current icu-data-full npm

USER 1000:1000
#token in url = tkn
ENTRYPOINT openvscode-server --host ${OPENVSCODE_HOST} --without-connection-token
# --connection-token ${OPENVSCODE_TOKEN}