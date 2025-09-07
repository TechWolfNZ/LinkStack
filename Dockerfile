# Stage 1: Build stage (Debian PHP + Composer)
FROM php:8.2-cli-bullseye AS build

WORKDIR /app

# Install system deps & PHP extensions
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    zip \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) gd zip pdo_mysql bcmath exif \
 && docker-php-ext-enable gd zip pdo_mysql bcmath exif

# Install Composer manually
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy dependency manifests first
# COPY composer.json composer.lock ./

#RUN composer require socialiteproviders/authentik

# Copy rest of the application
COPY . .

# Install PHP dependencies (including Authentik)
RUN composer install --no-dev --no-interaction --prefer-dist



# Stage 2: Runtime (LinkStack base image)
FROM linkstackorg/linkstack:latest

WORKDIR /var/www/html

# Copy everything from the build stage
COPY --from=build /app ./
