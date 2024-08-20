FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
		libfreetype-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
		gnupg \
        curl \
        zip \
        unzip \
        git \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install -j$(nproc) gd

# Tambahkan repositori Microsoft dan instal driver ODBC
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 unixodbc-dev

# Instal dan aktifkan ekstensi pdo_sqlsrv dan sqlsrv
RUN pecl install pdo_sqlsrv sqlsrv \
    && docker-php-ext-enable pdo_sqlsrv sqlsrv

# Instal Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Bersihkan cache apt
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/tanrise_admin

COPY . .

# RUN composer install --no-interaction --no-dev --prefer-dist

# CMD ["php-fpm", "-D"]
