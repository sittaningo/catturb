FROM rocker/rstudio:latest

# ── System dependencies ────────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-client \
    libxt-dev \
    python3 \
    python3-pip \
    wget \
    curl \
    cmake \
    protobuf-compiler \
    libfontconfig1 \
    libfreetype6 \
    libharfbuzz-dev \
    libfribidi-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ── TeX Live（apt経由・aarch64ネイティブ）────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    texlive-xetex \
    texlive-luatex \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-science \
    texlive-bibtex-extra \
    biber \
    latexmk \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ── titlesec を CTAN から最新版で上書き ──────────────────────────────────────
# TeX Live 2022/Debian の titlesec には \paragraph バグがあるため直接取得
RUN mkdir -p /usr/local/share/texmf/tex/latex/titlesec && \
    wget -q "https://mirrors.ctan.org/macros/latex/contrib/titlesec/titlesec.sty" \
         -O /usr/local/share/texmf/tex/latex/titlesec/titlesec.sty && \
    texhash /usr/local/share/texmf

# ── Julia ─────────────────────────────────────────────────────────────────────
ENV JULIA_MINOR_VERSION=1.9
ENV JULIA_PATCH_VERSION=2

RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "aarch64" ]; then JARCH="aarch64"; JDIR="aarch64"; \
    else JARCH="x86_64"; JDIR="x64"; fi && \
    wget -q \
      "https://julialang-s3.julialang.org/bin/linux/${JDIR}/${JULIA_MINOR_VERSION}/julia-${JULIA_MINOR_VERSION}.${JULIA_PATCH_VERSION}-linux-${JARCH}.tar.gz" \
      -O /tmp/julia.tar.gz && \
    tar xf /tmp/julia.tar.gz -C /opt && \
    rm /tmp/julia.tar.gz && \
    ln -s /opt/julia-${JULIA_MINOR_VERSION}.${JULIA_PATCH_VERSION}/bin/julia /usr/local/bin/julia

# ── pip PATH ──────────────────────────────────────────────────────────────────
ENV PATH="${PATH}:/home/rstudio/.pip/bin"

# ── Directory structure & permissions ─────────────────────────────────────────
RUN mkdir -p /home/rstudio/.pip \
               /home/rstudio/.cache/R/renv \
               /home/rstudio/.julia && \
    chown -R rstudio:rstudio \
               /home/rstudio/.pip \
               /home/rstudio/.cache \
               /home/rstudio/.julia

ENV TZ=Asia/Tokyo

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]