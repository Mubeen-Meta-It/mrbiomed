FROM php:8.2-cli

# System deps for gd + zip + mysql
RUN apt-get update && apt-get install -y \
    git unzip zip libzip-dev \
    libpng-dev libjpeg-dev libfreetype6-dev \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install gd zip pdo_mysql \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy code
COPY . .

# Install PHP deps (no scripts during build)
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts

# Start server on Railway port
CMD php -S 0.0.0.0:${PORT:-8080} -t public
