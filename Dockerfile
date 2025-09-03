FROM elixir:1.18-alpine

WORKDIR /app

# Copy mix files
COPY mix.exs mix.lock ./

# Install hex and get deps
RUN mix local.hex --force && \
    mix deps.get

# Copy source code
COPY . .

# Compile
RUN mix compile

# Default command
CMD ["mix", "test"]
