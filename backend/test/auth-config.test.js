const test = require('node:test');
const assert = require('node:assert/strict');
const {
    getJwtSecret,
    getRefreshTokenSecret
} = require('../src/config/auth');

function withEnv(values, callback) {
    const previous = {};
    for (const key of Object.keys(values)) {
        previous[key] = process.env[key];
        process.env[key] = values[key];
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

test('getJwtSecret rejects weak placeholder secrets', () => {
    withEnv({ JWT_SECRET: 'replace_with_a_strong_secret' }, () => {
        assert.throws(() => getJwtSecret(), /at least 32|placeholder/);
    });
});

test('getJwtSecret accepts strong random-looking secrets', () => {
    withEnv({ JWT_SECRET: 'A9kLm42_qRsT88vWxYzP17bCnD30eFgH' }, () => {
        assert.equal(getJwtSecret(), 'A9kLm42_qRsT88vWxYzP17bCnD30eFgH');
    });
});

test('getRefreshTokenSecret must differ from access token secret', () => {
    const secret = 'A9kLm42_qRsT88vWxYzP17bCnD30eFgH';
    withEnv({
        JWT_SECRET: secret,
        REFRESH_TOKEN_SECRET: secret
    }, () => {
        assert.throws(() => getRefreshTokenSecret(), /different/);
    });
});
