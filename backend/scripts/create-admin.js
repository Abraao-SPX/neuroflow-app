require('dotenv').config();

const sequelize = require('../src/config/sequelize');
const UserModel = require('../src/models/UserModel');
const {
    normalizeEmail,
    normalizeRequiredString,
    validatePassword
} = require('../src/utils/validation');

async function main() {
    const emailResult = normalizeEmail(process.env.ADMIN_EMAIL, { required: true });
    if (emailResult.error) {
        throw new Error(`ADMIN_EMAIL: ${emailResult.error}`);
    }

    const passwordResult = validatePassword(process.env.ADMIN_PASSWORD, 'ADMIN_PASSWORD');
    if (passwordResult.error) {
        throw new Error(passwordResult.error);
    }

    const usernameResult = normalizeRequiredString(
        process.env.ADMIN_USERNAME || 'admin',
        'ADMIN_USERNAME',
        { min: 3, max: 100 }
    );
    if (usernameResult.error) {
        throw new Error(usernameResult.error);
    }

    await sequelize.authenticate();

    const [user, created] = await UserModel.findOrCreate({
        where: { email: emailResult.value },
        defaults: {
            username: usernameResult.value,
            email: emailResult.value,
            password: passwordResult.value,
            role: 'admin'
        }
    });

    if (!created) {
        user.username = usernameResult.value;
        user.password = passwordResult.value;
        user.role = 'admin';
        await user.save();
    }

    console.log(`${created ? 'Admin created' : 'Admin updated'}: ${user.email}`);
}

main()
    .catch((error) => {
        console.error(error.message || error);
        process.exitCode = 1;
    })
    .finally(async () => {
        await sequelize.close();
    });
