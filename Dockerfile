FROM rocker/rstudio:latest

# ── System dependencies ────────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-client \
    libxt-dev \
    python3 \
    python3-pip \
    wget \
    curl \
    libfontconfig1 \
    libfreetype6 \
    libharfbuzz-dev \
    libfribidi-dev \
    cmake \
    protobuf-compiler \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ── Quarto CLI ─────────────────────────────────────────────────────────────────
ENV QUARTO_VERSION=1.5.57
RUN curl -fsSL \
    "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" \
    -o /tmp/quarto.deb \
    && dpkg -i /tmp/quarto.deb \
    && rm /tmp/quarto.deb

# ── TinyTeX (LaTeX) ────────────────────────────────────────────────────────────
# rstudio ユーザとしてインストール（tlmgr が正常動作するため）
USER rstudio
RUN wget -qO- "https://yihui.org/tinytex/install-bin-unix.sh" | sh && \
    ~/.TinyTeX/bin/*/tlmgr install \
      xetex \
      lualatex-math \
      luatexja \
      collection-fontsrecommended \
      collection-latexrecommended \
      collection-xetex \
      fontspec \
      unicode-math \
      haranoaji \
      haranoaji-extra \
      bxjscls \
      zxjatype \
      biber \
      biblatex \
      tcolorbox \
      pgf \
      etoolbox \
      booktabs \
      caption \
      float \
      fancyhdr \
      geometry \
      hyperref \
      xcolor \
      soul \
    && ~/.TinyTeX/bin/*/tlmgr path add

USER root
# システム全体からも参照できるようシンボリックリンク
RUN find /home/rstudio/.TinyTeX/bin -maxdepth 2 \
      \( -name lualatex -o -name xelatex -o -name pdflatex -o -name biber \) \
      -exec ln -sf {} /usr/local/bin/ \;

# ── Julia ─────────────────────────────────────────────────────────────────────
ENV JULIA_MINOR_VERSION=1.9
ENV JULIA_PATCH_VERSION=2

RUN wget -q \
    "https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_MINOR_VERSION}/julia-${JULIA_MINOR_VERSION}.${JULIA_PATCH_VERSION}-linux-x86_64.tar.gz" \
    -O /tmp/julia.tar.gz && \
    tar xf /tmp/julia.tar.gz -C /opt && \
    rm /tmp/julia.tar.gz && \
    ln -s /opt/julia-${JULIA_MINOR_VERSION}.${JULIA_PATCH_VERSION}/bin/julia /usr/local/bin/julia

# ── pip PATH ──────────────────────────────────────────────────────────────────
ENV PATH="${PATH}:/home/rstudio/.pip/bin"

# ── Directory structure & permissions ─────────────────────────────────────────
RUN mkdir -p /home/rstudio/.pip \
               /home/rstudio/.cache/R/renv \
               /home/rstudio/.TinyTeX \
               /home/rstudio/.julia && \
    chown -R rstudio:rstudio \
               /home/rstudio/.pip \
               /home/rstudio/.cache \
               /home/rstudio/.TinyTeX \
               /home/rstudio/.julia

ENV TZ=Asia/Tokyo