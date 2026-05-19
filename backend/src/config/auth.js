require('dotenv').config();

const WEAK_SECRET_VALUES = new Set([
    'secret',
    'changeme',
    'password',
    'replace_with_a_strong_secret',
    'replace_with_a_different_strong_refresh_secret',
    'generate_at_least_32_random_characters_for_access_tokens',
    'generate_a_different_32_random_character_refresh_secret',
    'sua_chave_jwt_secreta_e_segura',
    'sua_chave_refresh_secreta_e_segura'
]);

function validateSecret(name, value) {
    if (!value) {
        throw new Error(`${name} must be defined in the environment.`);
    }

    const normalized = String(value).trim();
    if (normalized.length < 32) {
        throw new Error(`${name} must have at least 32 characters.`);
    }

    if (WEAK_SECRET_VALUES.has(normalized.toLowerCase())) {
        throw new Error(`${name} must not use placeholder or example values.`);
    }

    if (new Set(normalized).size < 12) {
        throw new Error(`${name} must contain enough unique characters.`);
    }

    return normalized;
}

function getJwtSecret() {
    return validateSecret('JWT_SECRET', process.env.JWT_SECRET);
}

function getTokenExpiration() {
    if (!process.env.TOKEN_EXPIRATION) {
        throw new Error('TOKEN_EXPIRATION must be defined in the environment.');
    }

    return process.env.TOKEN_EXPIRATION;
}

function getRefreshTokenSecret() {
    const refreshSecret = validateSecret('REFRESH_TOKEN_SECRET', process.env.REFRESH_TOKEN_SECRET);
    if (refreshSecret === getJwtSecret()) {
        throw new Error('REFRESH_TOKEN_SECRET must be different from JWT_SECRET.');
    }

    return refreshSecret;
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
