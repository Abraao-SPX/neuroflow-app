function isProduction() {
    return process.env.NODE_ENV === 'production';
}

function requiredEnv(name, fallback) {
    const value = process.env[name];
    if (value !== undefined && value !== '') {
        return value;
    }

    if (isProduction()) {
        throw new Error(`${name} must be defined in production.`);
    }

    return fallback;
}

function parseBoolean(value, defaultValue = false) {
    if (value === undefined || value === null || value === '') {
        return defaultValue;
    }

    return ['1', 'true', 'yes', 'on'].includes(String(value).trim().toLowerCase());
}

function parsePort(value) {
    const port = Number(value || 3306);
    if (!Number.isInteger(port) || port < 1 || port > 65535) {
        throw new Error('DB_PORT must be an integer between 1 and 65535.');
    }

    return port;
}

function buildDialectOptions() {
    if (!parseBoolean(process.env.DB_SSL, false)) {
        return undefined;
    }

    const ssl = {
        require: true,
        rejectUnauthorized: parseBoolean(process.env.DB_SSL_REJECT_UNAUTHORIZED, true)
    };

    if (process.env.DB_SSL_CA) {
        ssl.ca = process.env.DB_SSL_CA;
    }

    return { ssl };
}

function buildSequelizeOptions() {
    const options = {
        host: requiredEnv('DB_HOST', 'localhost'),
        port: parsePort(process.env.DB_PORT),
        dialect: 'mysql',
        logging: process.env.DB_LOGGING === 'true' ? console.log : false,
        define: {
            timestamps: true,
            underscored: true
        }
    };

    const dialectOptions = buildDialectOptions();
    if (dialectOptions) {
        options.dialectOptions = dialectOptions;
    }

    return options;
}

function buildSequelizeCliConfig(databaseName) {
    return {
        username: requiredEnv('DB_USER', 'root'),
        password: requiredEnv('DB_PASSWORD', ''),
        database: databaseName || requiredEnv('DB_NAME', 'neuroflow_db'),
        ...buildSequelizeOptions()
    };
}

module.exports = {
    buildDialectOptions,
    buildSequelizeCliConfig,
    buildSequelizeOptions,
    parseBoolean,
    parsePort,
    requiredEnv
};
