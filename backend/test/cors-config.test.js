const assert = require('node:assert/strict');
const test = require('node:test');

const {
    getAllowedOrigins,
    isOriginAllowed
} = require('../src/config/cors');

test('CORS allows exact origins and requests without origin', () => {
    const allowedOrigins = ['http://localhost:3000'];

    assert.equal(isOriginAllowed(undefined, allowedOrigins), true);
    assert.equal(isOriginAllowed('http://localhost:3000', allowedOrigins), true);
    assert.equal(isOriginAllowed('http://localhost:5173', allowedOrigins), false);
});

test('CORS supports wildcard ports for configured origins', () => {
    const allowedOrigins = ['http://localhost:*', 'http://127.0.0.1:*'];

    assert.equal(isOriginAllowed('http://localhost:52741', allowedOrigins), true);
    assert.equal(isOriginAllowed('http://127.0.0.1:8080', allowedOrigins), true);
    assert.equal(isOriginAllowed('https://localhost:52741', allowedOrigins), false);
    assert.equal(isOriginAllowed('http://example.com:52741', allowedOrigins), false);
});

test('production requires configured CORS origins', () => {
    const originalNodeEnv = process.env.NODE_ENV;
    const originalCorsOrigins = process.env.CORS_ORIGINS;

    try {
        process.env.NODE_ENV = 'production';
        delete process.env.CORS_ORIGINS;

        assert.throws(
            () => getAllowedOrigins(),
            /CORS_ORIGINS must be defined in production/
        );
    } finally {
        process.env.NODE_ENV = originalNodeEnv;
        if (originalCorsOrigins === undefined) {
            delete process.env.CORS_ORIGINS;
        } else {
            process.env.CORS_ORIGINS = originalCorsOrigins;
        }
    }
});
