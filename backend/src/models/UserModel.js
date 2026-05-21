const bcrypt = require('bcrypt');
const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const { DataTypes, Model, Op } = require('sequelize');
const sequelize = require('../config/sequelize');
const { getJwtSecret, getTokenExpiration } = require('../config/auth');

function hashResetToken(token) {
    return crypto
        .createHmac('sha256', getJwtSecret())
        .update(String(token))
        .digest('hex');
}

class UserModel extends Model {
    toSafeJSON() {
        return {
            id: this.id,
            username: this.username,
            name: this.username,
            email: this.email,
            role: this.role,
            status: this.status
        };
    }

    static generateAccessToken(user) {
        return jwt.sign(
            {
                id: user.id,
                username: user.username,
                role: user.role
            },
            getJwtSecret(),
            {
                expiresIn: getTokenExpiration(),
                algorithm: 'HS256'
            }
        );
    }

    static generateToken(user) {
        return this.generateAccessToken(user);
    }

    static async findByEmail(email) {
        return this.findOne({ where: { email } });
    }

    static async findByUsername(username) {
        return this.findOne({ where: { username } });
    }

    static async findByLogin(identifier) {
        return this.findByEmail(identifier);
    }

    static async findByResetToken(token) {
        return this.findOne({
            where: {
                resetToken: hashResetToken(token),
                resetTokenExpires: {
                    [Op.gt]: new Date()
                }
            }
        });
    }

    static async updateResetToken(userId, token, expires) {
        await this.update(
            {
                resetToken: hashResetToken(token),
                resetTokenExpires: expires
            },
            { where: { id: userId } }
        );
    }

    static async updatePassword(userId, newPassword) {
        const user = await this.findByPk(userId);
        if (!user) return null;

        user.password = newPassword;
        user.resetToken = null;
        user.resetTokenExpires = null;
        await user.save();
        return user;
    }
}

UserModel.init(
    {
        id: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true
        },
        username: {
            type: DataTypes.STRING,
            allowNull: false,
            validate: {
                len: [3, 100]
            }
        },
        email: {
            type: DataTypes.STRING,
            allowNull: true,
            unique: true,
            validate: {
                isEmail: true
            }
        },
        password: {
            type: DataTypes.STRING,
            allowNull: false
        },
        role: {
            type: DataTypes.STRING,
            allowNull: false,
            defaultValue: 'user'
        },
        status: {
            type: DataTypes.STRING(20),
            allowNull: false,
            defaultValue: 'active',
            validate: {
                isIn: [['active', 'banned']]
            }
        },
        resetToken: {
            type: DataTypes.STRING,
            allowNull: true,
            field: 'reset_token'
        },
        resetTokenExpires: {
            type: DataTypes.DATE,
            allowNull: true,
            field: 'reset_token_expires'
        }
    },
    {
        sequelize,
        modelName: 'User',
        tableName: 'Usuarios',
        hooks: {
            beforeCreate: async (user) => {
                const salt = await bcrypt.genSalt(10);
                user.password = await bcrypt.hash(user.password, salt);
            },
            beforeUpdate: async (user) => {
                if (!user.changed('password')) return;

                const salt = await bcrypt.genSalt(10);
                user.password = await bcrypt.hash(user.password, salt);
            }
        }
    }
);

module.exports = UserModel;
