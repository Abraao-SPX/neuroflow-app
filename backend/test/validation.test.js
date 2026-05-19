const test = require('node:test');
const assert = require('node:assert/strict');
const {
    normalizeBoolean,
    normalizeDateOnly,
    normalizeEmail,
    normalizeOptionalString,
    normalizeRequiredString,
    parsePositiveInteger,
    validatePassword
} = require('../src/utils/validation');

test('parsePositiveInteger accepts only positive integer ids', () => {
    assert.equal(parsePositiveInteger('42'), 42);
    assert.equal(parsePositiveInteger('0'), null);
    assert.equal(parsePositiveInteger('-1'), null);
    assert.equal(parsePositiveInteger('42.5'), null);
    assert.equal(parsePositiveInteger('1abc'), null);
    assert.equal(parsePositiveInteger('abc'), null);
});

test('normalizeRequiredString trims and enforces limits', () => {
    assert.deepEqual(normalizeRequiredString('  tarefa  ', 'Titulo', { max: 20 }), { value: 'tarefa' });
    assert.match(normalizeRequiredString('', 'Titulo').error, /pelo menos/);
    assert.match(normalizeRequiredString('abc', 'Titulo', { max: 2 }).error, /maximo/);
});

test('normalizeOptionalString accepts null and trims empty strings to null', () => {
    assert.deepEqual(normalizeOptionalString(null, 'Descricao'), { value: null });
    assert.deepEqual(normalizeOptionalString('   ', 'Descricao'), { value: null });
    assert.deepEqual(normalizeOptionalString(' texto ', 'Descricao'), { value: 'texto' });
});

test('normalizeBoolean accepts common boolean payload formats', () => {
    assert.deepEqual(normalizeBoolean(true, 'Completed'), { value: true });
    assert.deepEqual(normalizeBoolean('0', 'Completed'), { value: false });
    assert.match(normalizeBoolean('talvez', 'Completed').error, /booleano/);
});

test('normalizeEmail validates and normalizes email', () => {
    assert.deepEqual(normalizeEmail(' USER@Example.COM ', { required: true }), { value: 'user@example.com' });
    assert.match(normalizeEmail('invalid', { required: true }).error, /invalido/);
    assert.match(normalizeEmail('', { required: true }).error, /obrigatorio/);
});

test('validatePassword requires a bounded alphanumeric password', () => {
    assert.deepEqual(validatePassword('abc12345'), { value: 'abc12345' });
    assert.match(validatePassword('abcdefghi').error, /letras e numeros/);
    assert.match(validatePassword('a1').error, /pelo menos/);
});

test('normalizeDateOnly validates YYYY-MM-DD dates', () => {
    assert.deepEqual(normalizeDateOnly('2026-05-19', 'Data'), { value: '2026-05-19' });
    assert.match(normalizeDateOnly('2026-02-30', 'Data').error, /valida/);
    assert.match(normalizeDateOnly('19/05/2026', 'Data').error, /YYYY-MM-DD/);
});
