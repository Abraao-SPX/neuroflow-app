function parseOrigins(value) {
    return String(value || '')
        .split(',')
        .map((origin) => origin.trim())
        .filter(Boolean);
}

function getAllowedOrigins() {
    const configuredOrigins = parseOrigins(process.env.CORS_ORIGINS);
    if (configuredOrigins.length > 0) {
        return configuredOrigins;
    }

    if (process.env.NODE_ENV === 'production') {
        throw new Error('CORS_ORIGINS must be defined in production.');
    }

    return [
        'http://localhost:3000',
        'http://localhost:5173',
        'http://localhost:8080',
        'http://127.0.0.1:3000',
        'http://127.0.0.1:5173',
        'http://10.0.2.2:3000'
    ];
}

function isWildcardPortMatch(allowedOrigin, requestOrigin) {
    if (!allowedOrigin.endsWith(':*')) {
        return false;
    }

    try {
        const allowedUrl = new URL(allowedOrigin.slice(0, -2));
        const requestUrl = new URL(requestOrigin);

        return allowedUrl.protocol === requestUrl.protocol
            && allowedUrl.hostname === requestUrl.hostname;
    } catch (_) {
        return false;
    }
}

function isOriginAllowed(origin, allowedOrigins) {
    if (!origin) {
        return true;
    }

    return allowedOrigins.some((allowedOrigin) => {
        return allowedOrigin === origin || isWildcardPortMatch(allowedOrigin, origin);
    });
}

function getCorsOptions() {
    const allowedOrigins = getAllowedOrigins();

    return {
        origin(origin, callback) {
            if (isOriginAllowed(origin, allowedOrigins)) {
                return callback(null, true);
            }

            return callback(new Error('Origem nao permitida pelo CORS.'));
        },
        methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
        allowedHeaders: ['Content-Type', 'Authorization'],
        credentials: false,
        maxAge: 600
    };
}

module.exports = {
    getAllowedOrigins,
    getCorsOptions,
    isOriginAllowed
};
