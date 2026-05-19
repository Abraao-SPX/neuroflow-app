function isPlainObject(value) {
    return Boolean(value) && typeof value === 'object' && !Array.isArray(value);
}

function parsePositiveInteger(value) {
    if (!/^\d+$/.test(String(value))) {
        return null;
    }

    const parsed = Number(value);
    return Number.isInteger(parsed) && parsed > 0 ? parsed : null;
}

function normalizeRequiredString(value, fieldName, { min = 1, max } = {}) {
    if (typeof value !== 'string') {
        return { error: `${fieldName} deve ser um texto.` };
    }

    const normalized = value.trim();
    if (normalized.length < min) {
        return { error: `${fieldName} deve ter pelo menos ${min} caractere(s).` };
    }

    if (max && normalized.length > max) {
        return { error: `${fieldName} deve ter no maximo ${max} caracteres.` };
    }

    return { value: normalized };
}

function normalizeOptionalString(value, fieldName, { max } = {}) {
    if (value === undefined) {
        return { omitted: true };
    }

    if (value === null) {
        return { value: null };
    }

    if (typeof value !== 'string') {
        return { error: `${fieldName} deve ser um texto.` };
    }

    const normalized = value.trim();
    if (max && normalized.length > max) {
        return { error: `${fieldName} deve ter no maximo ${max} caracteres.` };
    }

    return { value: normalized || null };
}

function normalizeBoolean(value, fieldName) {
    if (value === true || value === 'true' || value === 1 || value === '1') {
        return { value: true };
    }

    if (value === false || value === 'false' || value === 0 || value === '0') {
        return { value: false };
    }

    return { error: `${fieldName} deve ser booleano.` };
}

function normalizeEmail(value, { required = false } = {}) {
    if (value === undefined || value === null || value === '') {
        if (required) {
            return { error: 'E-mail e obrigatorio.' };
        }
        return { value: null };
    }

    if (typeof value !== 'string') {
        return { error: 'E-mail deve ser um texto.' };
    }

    const email = value.trim().toLowerCase();
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email) || email.length > 254) {
        return { error: 'E-mail invalido.' };
    }

    return { value: email };
}

function validatePassword(value, fieldName = 'Password') {
    if (typeof value !== 'string') {
        return { error: `${fieldName} deve ser um texto.` };
    }

    if (value.length < 8) {
        return { error: `${fieldName} deve ter pelo menos 8 caracteres.` };
    }

    if (value.length > 72) {
        return { error: `${fieldName} deve ter no maximo 72 caracteres.` };
    }

    if (!/[A-Za-z]/.test(value) || !/\d/.test(value)) {
        return { error: `${fieldName} deve conter letras e numeros.` };
    }

    return { value };
}

function normalizeDateOnly(value, fieldName) {
    if (typeof value !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(value)) {
        return { error: `${fieldName} deve usar o formato YYYY-MM-DD.` };
    }

    const parsed = new Date(`${value}T00:00:00.000Z`);
    if (Number.isNaN(parsed.getTime()) || parsed.toISOString().slice(0, 10) !== value) {
        return { error: `${fieldName} deve ser uma data valida.` };
    }

    return { value };
}

function isUniqueConstraintError(error) {
    return error?.name === 'SequelizeUniqueConstraintError' || error?.code === 'ER_DUP_ENTRY';
}

module.exports = {
    isPlainObject,
    isUniqueConstraintError,
    normalizeBoolean,
    normalizeDateOnly,
    normalizeEmail,
    normalizeOptionalString,
    normalizeRequiredString,
    parsePositiveInteger,
    validatePassword
};
