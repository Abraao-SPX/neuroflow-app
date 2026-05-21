const test = require('node:test');
const assert = require('node:assert/strict');
const TaskController = require('../src/controllers/TaskController');
const TaskModel = require('../src/models/TaskModel');

function createResponse() {
    return {
        statusCode: undefined,
        body: undefined,
        sent: false,
        status(code) {
            this.statusCode = code;
            return this;
        },
        json(payload) {
            this.body = payload;
            return this;
        },
        send(payload) {
            this.sent = true;
            this.body = payload;
            return this;
        }
    };
}

async function withTaskModelStub(stubs, callback) {
    const previous = {};
    for (const key of Object.keys(stubs)) {
        previous[key] = TaskModel[key];
        TaskModel[key] = stubs[key];
    }

    try {
        await callback();
    } finally {
        for (const [key, value] of Object.entries(previous)) {
            TaskModel[key] = value;
        }
    }
}

test('TaskController lists only tasks for the authenticated user', async () => {
    await withTaskModelStub({
        getAllByUser: async (userId) => {
            assert.equal(userId, 7);
            return [{ id: 1, title: 'Regular sono', completed: false }];
        }
    }, async () => {
        const res = createResponse();
        await TaskController.getTasks({ userId: 7 }, res);

        assert.equal(res.statusCode, 200);
        assert.deepEqual(res.body, {
            success: true,
            data: [{ id: 1, title: 'Regular sono', completed: false }]
        });
    });
});

test('TaskController creates a task with normalized data and authenticated user id', async () => {
    await withTaskModelStub({
        create: async (payload) => {
            assert.deepEqual(payload, {
                userId: 7,
                title: 'Estudar',
                description: null
            });
            return { id: 10, title: 'Estudar', description: null, completed: false };
        }
    }, async () => {
        const res = createResponse();
        await TaskController.createTask({
            userId: 7,
            body: { title: '  Estudar  ', description: '   ' }
        }, res);

        assert.equal(res.statusCode, 201);
        assert.equal(res.body.success, true);
        assert.equal(res.body.data.id, 10);
    });
});

test('TaskController blocks parent write access', async () => {
    let createWasCalled = false;
    await withTaskModelStub({
        create: async () => {
            createWasCalled = true;
        }
    }, async () => {
        const res = createResponse();
        await TaskController.createTask({
            userId: 7,
            userRole: 'parent',
            body: { title: 'Estudar' }
        }, res);

        assert.equal(res.statusCode, 403);
        assert.equal(res.body.success, false);
        assert.equal(createWasCalled, false);
    });
});

test('TaskController rejects invalid create payloads before persistence', async () => {
    let createWasCalled = false;
    await withTaskModelStub({
        create: async () => {
            createWasCalled = true;
        }
    }, async () => {
        const res = createResponse();
        await TaskController.createTask({ userId: 7, body: { title: '' } }, res);

        assert.equal(res.statusCode, 400);
        assert.equal(createWasCalled, false);
    });
});

test('TaskController reads a single task by id scoped to the authenticated user', async () => {
    await withTaskModelStub({
        findById: async (taskId, userId) => {
            assert.equal(taskId, 42);
            assert.equal(userId, 7);
            return { id: 42, title: 'Alongar', completed: false };
        }
    }, async () => {
        const res = createResponse();
        await TaskController.getTaskById({
            userId: 7,
            params: { id: '42' }
        }, res);

        assert.equal(res.statusCode, 200);
        assert.equal(res.body.data.id, 42);
    });
});

test('TaskController rejects malformed task ids', async () => {
    let findWasCalled = false;
    await withTaskModelStub({
        findById: async () => {
            findWasCalled = true;
        }
    }, async () => {
        const res = createResponse();
        await TaskController.getTaskById({
            userId: 7,
            params: { id: '42abc' }
        }, res);

        assert.equal(res.statusCode, 400);
        assert.equal(findWasCalled, false);
    });
});

test('TaskController updates a task with partial PATCH data', async () => {
    await withTaskModelStub({
        update: async (taskId, userId, data) => {
            assert.equal(taskId, 42);
            assert.equal(userId, 7);
            assert.deepEqual(data, { completed: true });
            return { id: 42, title: 'Alongar', completed: true };
        }
    }, async () => {
        const res = createResponse();
        await TaskController.updateTask({
            userId: 7,
            params: { id: '42' },
            body: { completed: 'true' }
        }, res);

        assert.equal(res.statusCode, 200);
        assert.equal(res.body.data.completed, true);
    });
});

test('TaskController requires complete data for PUT replacement', async () => {
    let updateWasCalled = false;
    await withTaskModelStub({
        update: async () => {
            updateWasCalled = true;
        }
    }, async () => {
        const res = createResponse();
        await TaskController.replaceTask({
            userId: 7,
            params: { id: '42' },
            body: { title: 'Nova tarefa' }
        }, res);

        assert.equal(res.statusCode, 400);
        assert.equal(updateWasCalled, false);
    });
});

test('TaskController deletes a task scoped to the authenticated user', async () => {
    await withTaskModelStub({
        delete: async (taskId, userId) => {
            assert.equal(taskId, 42);
            assert.equal(userId, 7);
            return true;
        }
    }, async () => {
        const res = createResponse();
        await TaskController.deleteTask({
            userId: 7,
            params: { id: '42' }
        }, res);

        assert.equal(res.statusCode, 204);
        assert.equal(res.sent, true);
    });
});
