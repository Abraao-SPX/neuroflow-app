require('dotenv').config();

function getJwtSecret() {
    if (!process.env.JWT_SECRET) {
        throw new Error('JWT_SECRET must be defined in the environment.');
    }

    return process.env.JWT_SECRET;
}

function getTokenExpiration() {
    if (!process.env.TOKEN_EXPIRATION) {
        throw new Error('TOKEN_EXPIRATION must be defined in the environment.');
    }

    return process.env.TOKEN_EXPIRATION;
}

function getRefreshTokenSecret() {
    if (!process.env.REFRESH_TOKEN_SECRET) {
        throw new Error('REFRESH_TOKEN_SECRET must be defined in the environment.');
    }

    return process.env.REFRESH_TOKEN_SECRET;
}

function getRefreshTokenExpiration() {
    if (!process.env.REFRESH_TOKEN_EXPIRATION) {
        throw new Error('REFRESH_TOKEN_EXPIRATION must be defined in the environment.');
    }

    return process.env.REFRESH_TOKEN_EXPIRATION;
}

module.exports = {
    getJwtSecret,
    getTokenExpiration,
    getRefreshTokenSecret,
    getRefreshTokenExpiration
};
