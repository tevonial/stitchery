# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/devcontainers/typescript-node:22-bookworm
WORKDIR /workspace

ARG USERNAME=node
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && mkdir /commandhistory \
    && touch /commandhistory/.bash_history \
    && chown -R $USERNAME /commandhistory \
    && echo "$SNIPPET" >> "/home/$USERNAME/.bashrc"

CMD ["tail", "-f", "/dev/null"]
