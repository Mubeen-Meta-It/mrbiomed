FROM php:8.2-cli

# -----------------------------
# System deps (PHP extensions)
# -----------------------------
RUN apt-get update && apt-get install -y \
    git unzip zip curl \
    libzip-dev \
    libpng-dev libjpeg-dev libfreetype6-dev \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install gd zip pdo_mysql \
  && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Install Node.js (LTS)
# -----------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
  && apt-get install -y nodejs

WORKDIR /app

# -----------------------------
# Composer
# -----------------------------
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# -----------------------------
# Copy source
# -----------------------------
COPY . .

# -----------------------------
# PHP deps
# -----------------------------
RUN composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction \
    --no-scripts

# -----------------------------
# Frontend build
# -----------------------------
RUN npm install
RUN npm run dev

# -----------------------------
# Start Laravel
# -----------------------------
CMD php -S 0.0.0.0:${PORT:-8080} -t public
