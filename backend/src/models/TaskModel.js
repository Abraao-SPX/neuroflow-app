// Mock de dados temporário para simular o Banco de Dados (MySQL)
let mockTasks = [
    { id: 1, title: 'Organizar mochila', description: 'Preparar a mochila para o dia de amanhã visando reduzir a ansiedade.', completed: false },
    { id: 2, title: 'Horário do Remédio', description: 'Tomar medicação pontualmente.', completed: true }
];

class TaskModel {
    static async getAll() {
        // Simulando atraso de rede/I/O do MySQL
        return new Promise((resolve) => {
            setTimeout(() => resolve(mockTasks), 300);
        });
    }

    static async create(task) {
        return new Promise((resolve) => {
            setTimeout(() => {
                const newTask = { 
                    id: mockTasks.length > 0 ? mockTasks[mockTasks.length - 1].id + 1 : 1, 
                    ...task, 
                    completed: false 
                };
                mockTasks.push(newTask);
                resolve(newTask);
            }, 300);
        });
    }

    static async update(id, taskData) {
        return new Promise((resolve) => {
            setTimeout(() => {
                const index = mockTasks.findIndex(t => t.id === parseInt(id));
                if (index === -1) return resolve(null);
                
                mockTasks[index] = { ...mockTasks[index], ...taskData };
                resolve(mockTasks[index]);
            }, 300);
        });
    }

    static async delete(id) {
        return new Promise((resolve) => {
            setTimeout(() => {
                const index = mockTasks.findIndex(t => t.id === parseInt(id));
                if (index === -1) return resolve(false);
                
                mockTasks.splice(index, 1);
                resolve(true);
            }, 300);
        });
    }
}

module.exports = TaskModel;
