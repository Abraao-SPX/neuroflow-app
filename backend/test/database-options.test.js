const test = require('node:test');
const assert = require('node:assert/strict');
const {
    buildSequelizeCliConfig,
    buildSequelizeOptions,
    parseBoolean,
    parsePort,
    requiredEnv
} = require('../src/config/databaseOptions');

function withEnv(values, callback) {
    const previous = {};
    const keys = new Set([...Object.keys(values), 'NODE_ENV']);

    for (const key of keys) {
        previous[key] = process.env[key];
    }

    for (const [key, value] of Object.entries(values)) {
        if (value === undefined) {
            delete process.env[key];
        } else {
            process.env[key] = value;
        }
    }

    try {
        callback();
    } finally {
        for (const [key, value] of Object.entries(previous)) {
            if (value === undefined) {
                delete process.env[key];
            } else {
                process.env[key] = value;
            }
        }
    }
}

test('parseBoolean understands common true values and defaults', () => {
    assert.equal(parseBoolean(undefined, true), true);
    assert.equal(parseBoolean('true'), true);
    assert.equal(parseBoolean('1'), true);
    assert.equal(parseBoolean('yes'), true);
    assert.equal(parseBoolean('false'), false);
});

test('parsePort rejects invalid database ports', () => {
    assert.equal(parsePort(undefined), 3306);
    assert.equal(parsePort('3307'), 3307);
    assert.throws(() => parsePort('abc'), /DB_PORT/);
    assert.throws(() => parsePort('70000'), /DB_PORT/);
});

test('requiredEnv rejects missing database values in production', () => {
    withEnv({ NODE_ENV: 'production', DB_PASSWORD: undefined }, () => {
        assert.throws(() => requiredEnv('DB_PASSWORD', ''), /production/);
    });
});

test('buildSequelizeOptions includes port and SSL when enabled', () => {
    withEnv({
        NODE_ENV: 'development',
        DB_HOST: 'db.internal',
        DB_PORT: '3307',
        DB_SSL: 'true',
        DB_SSL_REJECT_UNAUTHORIZED: 'false'
    }, () => {
        const options = buildSequelizeOptions();
        assert.equal(options.host, 'db.internal');
        assert.equal(options.port, 3307);
        assert.equal(options.dialect, 'mysql');
        assert.deepEqual(options.dialectOptions.ssl, {
            require: true,
            rejectUnauthorized: false
        });
    });
});

test('buildSequelizeCliConfig centralizes runtime and migration config', () => {
    withEnv({
        NODE_ENV: 'development',
        DB_USER: 'app',
        DB_PASSWORD: 'secret',
        DB_HOST: 'mysql',
        DB_PORT: '3306',
        DB_SSL: 'false'
    }, () => {
        const config = buildSequelizeCliConfig('neuroflow_test');
        assert.equal(config.username, 'app');
        assert.equal(config.password, 'secret');
        assert.equal(config.database, 'neuroflow_test');
        assert.equal(config.host, 'mysql');
        assert.equal(config.dialect, 'mysql');
    });
});
