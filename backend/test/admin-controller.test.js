const test = require('node:test');
const assert = require('node:assert/strict');
const sequelize = require('../src/config/sequelize');
const AdminController = require('../src/controllers/AdminController');
const RefreshTokenModel = require('../src/models/RefreshTokenModel');
const UserModel = require('../src/models/UserModel');

function createResponse() {
    return {
        statusCode: undefined,
        body: undefined,
        status(code) {
            this.statusCode = code;
            return this;
        },
        json(payload) {
            this.body = payload;
            return this;
        },
        send(payload) {
            this.body = payload;
            return this;
        }
    };
}

function createTransaction() {
    return {
        committed: false,
        rolledBack: false,
        async commit() {
            this.committed = true;
        },
        async rollback() {
            this.rolledBack = true;
        }
    };
}

async function withStubs(stubs, callback) {
    const previous = [];
    for (const [target, methods] of stubs) {
        for (const [key, value] of Object.entries(methods)) {
            previous.push([target, key, target[key]]);
            target[key] = value;
        }
    }

    try {
        await callback();
    } finally {
        for (const [target, key, value] of previous.reverse()) {
            target[key] = value;
        }
    }
}

test('AdminController returns users with account summary', async () => {
    await withStubs([
        [UserModel, {
            findAll: async () => [
                { id: 1, username: 'Ana', email: 'ana@test.com', role: 'admin', status: 'active', createdAt: '2026-05-21' },
                { id: 2, username: 'Beto', email: 'beto@test.com', role: 'user', status: 'banned', createdAt: '2026-05-21' },
                { id: 3, username: 'Caio', email: 'caio@test.com', role: 'user', status: 'active', createdAt: '2026-05-21' }
            ]
        }]
    ], async () => {
        const res = createResponse();
        await AdminController.getAllUsers({}, res);

        assert.equal(res.statusCode, 200);
        assert.equal(res.body.data.length, 3);
        assert.deepEqual(res.body.summary, {
            total: 3,
            active: 2,
            banned: 1,
            admins: 1
        });
    });
});

test('AdminController bans a user and revokes refresh tokens', async () => {
    const transaction = createTransaction();
    const user = {
        id: 8,
        username: 'Beto',
        email: 'beto@test.com',
        role: 'user',
        status: 'active',
        createdAt: '2026-05-21',
        async save(options) {
            assert.equal(options.transaction, transaction);
        }
    };

    await withStubs([
        [sequelize, { transaction: async () => transaction }],
        [UserModel, { findByPk: async () => user }],
        [RefreshTokenModel, {
            destroy: async ({ where, transaction: receivedTransaction }) => {
                assert.deepEqual(where, { userId: 8 });
                assert.equal(receivedTransaction, transaction);
            }
        }]
    ], async () => {
        const res = createResponse();
        await AdminController.setUserBanStatus({
            userId: 1,
            params: { id: '8' },
            body: { banned: true }
        }, res);

        assert.equal(transaction.committed, true);
        assert.equal(transaction.rolledBack, false);
        assert.equal(user.status, 'banned');
        assert.equal(res.statusCode, 200);
        assert.equal(res.body.data.status, 'banned');
    });
});

test('AdminController promotes an active user to admin', async () => {
    const transaction = createTransaction();
    const user = {
        id: 9,
        username: 'Caio',
        email: 'caio@test.com',
        role: 'user',
        status: 'active',
        createdAt: '2026-05-21',
        async save(options) {
            assert.equal(options.transaction, transaction);
        }
    };

    await withStubs([
        [sequelize, { transaction: async () => transaction }],
        [UserModel, { findByPk: async () => user }]
    ], async () => {
        const res = createResponse();
        await AdminController.promoteUserToAdmin({
            userId: 1,
            params: { id: '9' }
        }, res);

        assert.equal(transaction.committed, true);
        assert.equal(transaction.rolledBack, false);
        assert.equal(user.role, 'admin');
        assert.equal(res.statusCode, 200);
        assert.equal(res.body.data.role, 'admin');
    });
});
