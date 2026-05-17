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

module.exports = {
    getJwtSecret,
    getTokenExpiration
};
